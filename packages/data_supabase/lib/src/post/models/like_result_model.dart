import 'package:domain/post.dart';
import 'package:json_annotation/json_annotation.dart';

part 'like_result_model.g.dart';

@JsonSerializable(createToJson: false)
class LikeResultModel extends LikeResult {
  const LikeResultModel({required super.liked, required super.likesCount});

  factory LikeResultModel.fromJson(Map<String, dynamic> json) =>
      _$LikeResultModelFromJson(json);

  @JsonKey(name: 'likes_count')
  @override
  int get likesCount;
}
