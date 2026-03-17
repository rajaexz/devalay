import 'package:devalay_app/src/data/model/contribution/contribution_devalay_model.dart';
import 'package:devalay_app/src/data/model/contribution/donateModel.dart';

import '../../../data/model/contribution/accept_banner_model.dart';
import '../../../data/model/contribution/common_model.dart';
import '../../../data/model/contribution/donatePaymentModel.dart';

abstract class ContributeTempleState {}

class ContributeTempleInitial extends ContributeTempleState {}

class ContributeTempleLoaded extends ContributeTempleState {
  final List<ContributionDevalayModel>? templeList;
  final ContributionDevalayModel? singleTemple;
  AcceptBannerModel? acceptBannerModel;
  DonateModel? donateModel;
  DonatePaymentModel? donatePaymentModel;
  CommonModel? commonModel;
  String? templeId;
  String? governingId;
  bool loadingState;
  bool hasError;
  bool isPermissionDenied;
  String errorMessage;
  int? currentPage;

  final List<dynamic> locationResults;
  final bool locationLoading;
  final String? locationError;

  ContributeTempleLoaded(
      {this.templeList,
      this.singleTemple,
      this.commonModel,
      this.donateModel,
      this.donatePaymentModel,
      this.acceptBannerModel,
      this.templeId,
      this.governingId,
      required this.loadingState,
      this.hasError = false,
       this.currentPage,
      this.isPermissionDenied = false,
      this.errorMessage = '',

        this.locationResults = const [],
        this.locationLoading = false,
        this.locationError
      });

  ContributeTempleLoaded copyWith({
    List<ContributionDevalayModel>? templeList,
    ContributionDevalayModel? singleTemple,
    AcceptBannerModel? acceptBannerModel,
    DonateModel? donateModel,
    DonatePaymentModel? donatePaymentModel,
    CommonModel? commonModel,
    String? templeId,
    String? governingId,
    bool? loadingState,
    bool? hasError,
    String? errorMessage,
    int? currentPage,
    Map<String, int>? selectedItems,

    List<dynamic>? locationResults,
    bool? locationLoading,
    String? locationError
  }) {
    return ContributeTempleLoaded(
      templeList: templeList ?? this.templeList,
      singleTemple: singleTemple ?? this.singleTemple,
      acceptBannerModel: acceptBannerModel ?? this.acceptBannerModel,
      donateModel: donateModel ?? this.donateModel,
      donatePaymentModel: donatePaymentModel ?? this.donatePaymentModel,
      commonModel: commonModel ?? this.commonModel,
      templeId: templeId ?? this.templeId,
      governingId: governingId ?? this.governingId,
      loadingState: loadingState ?? this.loadingState,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,

      locationResults: locationResults ?? this.locationResults,
      locationLoading: locationLoading ?? this.locationLoading,
      locationError: locationError ?? this.locationError
    );
  }
}

class ContributeTempleError extends ContributeTempleState {
  final String message;
  final bool isPermissionDenied;

  ContributeTempleError({
    required this.message,
    this.isPermissionDenied = false,
  });
}
