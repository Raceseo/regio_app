import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../global_variables.dart';

class NoticeFormScreen extends StatefulWidget {
  const NoticeFormScreen({super.key});

  @override
  State<NoticeFormScreen> createState() => _NoticeFormScreenState();
}

class _NoticeFormScreenState extends State<NoticeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = 'internal';

  XFile? _pickedImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  void _submitNotice() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    _formKey.currentState!.save();
    setState(() {
      _isSaving = true;
    });

    print("========= 공지 저장 프로세스 시작 =========");

    try {
      String? uploadedImageUrl;
      if (_pickedImage != null) {
        print(">> 1단계: 이미지 업로드 시작...");
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('notice_images')
            .child('${globalUserId}_${DateTime.now().toIso8601String()}.jpg');

        if (kIsWeb) {
          await storageRef.putData(await _pickedImage!.readAsBytes());
        } else {
          await storageRef.putFile(File(_pickedImage!.path));
        }
        print(">> 2단계: 이미지 업로드 완료!");

        print(">> 3단계: 다운로드 URL 요청 시작...");
        uploadedImageUrl = await storageRef.getDownloadURL();
        print(">> 4단계: 다운로드 URL 받기 완료!");
      }

      final noticeData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'userId': globalUserId,
        'userName': globalUserName,
        'category': _selectedCategory,
        'imageUrl': uploadedImageUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      print(">> 5단계: Firestore에 데이터 저장 시작...");
      await FirebaseFirestore.instance.collection('notices').add(noticeData);
      print(">> 6단계: Firestore에 데이터 저장 완료!");

      if (mounted) {
        print(">> 7단계: 저장 성공! 화면을 빠져나갑니다.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('새 공지가 성공적으로 작성되었습니다.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print("!!!!!!!!!!! 저장 중 심각한 에러 발생 !!!!!!!!!!!");
      print("에러 종류: ${e.runtimeType}");
      print("에러 내용: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
    print("========= 공지 저장 프로세스 종료 =========");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지/소식 문서 작성'),
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
                decoration: const InputDecoration(labelText: '문서 제목'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? '제목을 입력해주세요.'
                    : null,
              ),
              const SizedBox(height: 24),
              Text('카테고리 선택', style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('내부 공지'),
                      value: 'internal',
                      groupValue: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('상급평의회'),
                      value: 'upper_council',
                      groupValue: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: kIsWeb
                                ? Image.network(_pickedImage!.path,
                                    fit: BoxFit.cover)
                                : Image.file(File(_pickedImage!.path),
                                    fit: BoxFit.cover),
                          )
                        : const Text('사진 없음',
                            style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('사진 선택'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '내용을 입력하세요',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 10,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? '내용을 입력해주세요.'
                    : null,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _submitNotice,
                    icon: _isSaving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? '저장 중...' : '문서 작성'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
