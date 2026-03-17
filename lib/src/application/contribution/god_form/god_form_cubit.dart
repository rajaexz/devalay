import 'package:devalay_app/injection.dart';
import 'package:devalay_app/src/application/contribution/god_form/god_form_state.dart';
import 'package:devalay_app/src/data/model/contribution/avatar_model.dart';
import 'package:devalay_app/src/data/model/contribution/god_form_model.dart';
import 'package:devalay_app/src/domain/repo_impl/contribution_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/contribution/temple_list_model.dart';

class GodFormCubit extends Cubit<GodFormState> {
  GodFormCubit()
      : contributeRepo = getIt<ContributeRepo>(),
        super(GodFormInitial());

  ContributeRepo contributeRepo;

  void fetchGodForm() async {
    setScreenState(isLoading: true);

    final result = await contributeRepo.fetchGodFormData();

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = (customResponse.response?.data as List)
          .map((x) => GodFormModel.fromJson(x))
          .toList();
      setScreenState(isLoading: false, data: data);
    });
  }

  void fetchAvatarForm() async {
    setScreenState(isLoading: true);

    final result = await contributeRepo.fetchAvatarFormData();

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = (customResponse.response?.data as List)
          .map((x) => AvatarModel.fromJson(x))
          .toList();
      setScreenState(isLoading: false, avatar: data);
    });
  }

  void fetchGodTempleData() async {
    setScreenState(isLoading: true);

    final result = await contributeRepo.fetchGodTempleData();

    result.fold((failure) {
      setScreenState(isLoading: false, message: failure.toString());
    }, (customResponse) {
      final data = (customResponse.response?.data as List)
          .map((x) => TempleListModel.fromJson(x))
          .toList();
      setScreenState(isLoading: false, templeList: data);
    });
  }

  void setScreenState(
      {List<GodFormModel>? data,
      List<TempleListModel>? templeList,
      List<AvatarModel>? avatar,
      required bool isLoading,
      String? message}) {
    emit(GodFormLoaded(
        godList: data,
        templeList: templeList,
        avatarList: avatar,
        loadingState: isLoading,
        errorMessage: message ?? ''));
  }
}
