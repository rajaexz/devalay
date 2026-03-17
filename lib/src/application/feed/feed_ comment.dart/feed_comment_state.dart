import 'package:devalay_app/src/data/model/feed/feed_comment_model.dart';
import 'package:devalay_app/src/data/model/feed/feed_comment_reply_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class FeedCommentState {}

class FeedCommentInitial extends FeedCommentState {}

class FeedCommentLoaded extends FeedCommentState {
  List<XFile>? selectedMedia;
  FeedCommentReply? singlefeedCommentList;
  List<FeedComment>? feedCommentList;
  List<FeedCommentReply>? feedCommentReplyList;
  List<FeedCommentReply>? feedReplyttoRepliesList;
  bool loadingState;
  bool hasError;
  String errorMessage;

  FeedCommentLoaded(
      {this.feedCommentList,
      this.selectedMedia,
      required this.loadingState,
      this.feedCommentReplyList,
      this.feedReplyttoRepliesList,
      this.singlefeedCommentList,
      this.hasError = false,
      this.errorMessage = ''});
}
