// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:devalay_app/src/data/repositories/authentication_repositories.dart'
    as _i852;
import 'package:devalay_app/src/data/repositories/contribution_repositories.dart'
    as _i912;
import 'package:devalay_app/src/data/repositories/explore_repositories.dart'
    as _i724;
import 'package:devalay_app/src/data/repositories/feed_repositories.dart'
    as _i146;
import 'package:devalay_app/src/data/repositories/kirti_repositories.dart'
    as _i726;
import 'package:devalay_app/src/data/repositories/profile_repositories.dart'
    as _i83;
import 'package:devalay_app/src/domain/repo_impl/authentication_repo.dart'
    as _i926;
import 'package:devalay_app/src/domain/repo_impl/contribution_repo.dart'
    as _i515;
import 'package:devalay_app/src/domain/repo_impl/explore_repo.dart' as _i494;
import 'package:devalay_app/src/domain/repo_impl/feed_repo.dart' as _i1061;
import 'package:devalay_app/src/domain/repo_impl/kirti_repo.dart' as _i796;
import 'package:devalay_app/src/domain/repo_impl/profile_repo.dart' as _i450;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i450.ProfileRepo>(() => _i83.ProfileRepositories());
    gh.lazySingleton<_i494.ExploreRepo>(() => _i724.ExploreRepositories());
    gh.lazySingleton<_i515.ContributeRepo>(
        () => _i912.ContributeRepositories());
    gh.lazySingleton<_i796.KirtiRepo>(() => _i726.KirtiRepositories());
    gh.lazySingleton<_i1061.FeedHomeRepo>(() => _i146.FeedHomeRepositories());
    gh.lazySingleton<_i926.AuthenticationRepo>(
        () => _i852.AuthenticationRepositories());
    return this;
  }
}
