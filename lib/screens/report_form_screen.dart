import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/activity_report.dart';
import '../global_variables.dart';

class ReportFormScreen extends StatefulWidget {
  final ActivityReport? report;
  const ReportFormScreen({super.key, this.report});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _unitNameController;

  XFile? _pickedImage;
  String? _networkImageUrl;
  bool _isSaving = false;

  bool get _isEditing => widget.report != null;

  @override
  void initState() {
    super.initState();
    final initialReport = widget.report;
    if (initialReport != null) {
      _titleController = TextEditingController(text: initialReport.title);
      _contentController = TextEditingController(text: initialReport.content);
      _unitNameController = TextEditingController(text: initialReport.unitName);
      _networkImageUrl = initialReport.imageUrl;
    } else {
      _titleController = TextEditingController();
      _contentController = TextEditingController();
      _unitNameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _unitNameController.dispose();
    super.dispose();
  }

  // ⭐️ 1. 이미지를 가져오는 로직을 별도 함수로 분리
  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  // ⭐️ 2. 카메라/갤러리 선택창을 띄우는 함수 추가
  void _showImageSourceDialog() {
    if (kIsWeb) {
      _getImage(ImageSource.gallery);
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(ctx).pop();
                }),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                _getImage(ImageSource.gallery);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
    });

    try {
      String uploadedImageUrl = _networkImageUrl ?? '';
      if (_pickedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('activity_images')
            .child('${globalUserId}_${DateTime.now().toIso8601String()}.jpg');
        if (kIsWeb) {
          await storageRef.putData(await _pickedImage!.readAsBytes());
        } else {
          await storageRef.putFile(File(_pickedImage!.path));
        }
        uploadedImageUrl = await storageRef.getDownloadURL();
      }
      final reportData = {
        'userId': globalUserId,
        'userName': globalUserName,
        'title': _titleController.text,
        'content': _contentController.text,
        'unitName': _unitNameController.text,
        'imageUrl': uploadedImageUrl,
        'timestamp': Timestamp.now(),
      };
      if (_isEditing) {
        await FirebaseFirestore.instance
            .collection('activities')
            .doc(widget.report!.id)
            .update(reportData);
      } else {
        await FirebaseFirestore.instance
            .collection('activities')
            .add(reportData);
      }
      if (mounted) {
        final message = _isEditing ? '보고서가 수정되었습니다.' : '보고서가 작성되었습니다.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')));
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '활동 보고서 수정' : '활동 보고서 작성'),
        actions: [
          IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isSaving ? null : _submitForm)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '보고서 제목'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? '제목을 입력하세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitNameController,
                decoration:
                    const InputDecoration(labelText: '소속 (예: 바다의 별 Pr.)'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? '소속을 입력하세요.' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: _pickedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(7.0),
                              child: kIsWeb
                                  ? Image.network(_pickedImage!.path,
                                      fit: BoxFit.cover)
                                  : Image.file(File(_pickedImage!.path),
                                      fit: BoxFit.cover))
                          : (_networkImageUrl != null &&
                                  _networkImageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(7.0),
                                  child: Image.network(_networkImageUrl!,
                                      fit: BoxFit.cover))
                              : const Text('사진 없음')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    // ⭐️ 3. 버튼 클릭 시 선택창을 띄우도록 변경
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('사진 선택'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '활동 내용',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) =>
                    (value == null || value.isEmpty) ? '내용을 입력하세요.' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitForm,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check),
                  label: Text(
                      _isSaving ? '저장 중...' : (_isEditing ? '수정 완료' : '작성 완료')),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
