// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../models/course_model.dart';

// class CourseService {
//   final supabase = Supabase.instance.client;

//   Future<List<CourseModel>> getAllCourses() async {
//     final response = await supabase
//         .from('courses')
//         .select()
//         .order('nama_mk', ascending: true);

//     if (response == null || response.isEmpty) return [];

//     return (response as List)
//         .map((e) => CourseModel.fromMap(e))
//         .toList();
//   }
// }
