import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_components/widgets/digit_dialog.dart';
import 'package:digit_components/widgets/digit_icon_tile.dart';

import 'package:digit_data_model/data_model.dart';
import 'package:digit_showcase/showcase_widget.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/services/location_bloc.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/helper_widget/digit_profile.dart';
import 'package:digit_ui_components/widgets/molecules/hamburger.dart';
import 'package:digit_ui_components/widgets/molecules/show_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:health_campaign_field_worker_app/widgets/showcase/showcase_wrappers.dart';
import 'package:isar/isar.dart';
import 'package:location/location.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:registration_delivery/models/entities/household.dart';
import 'package:registration_delivery/models/entities/household_member.dart';
import 'package:registration_delivery/models/entities/project_beneficiary.dart';
import 'package:registration_delivery/models/entities/referral.dart';
import 'package:registration_delivery/models/entities/side_effect.dart';
import 'package:registration_delivery/models/entities/task.dart';
import 'package:sync_service/sync_service_lib.dart';
import 'package:survey_form/survey_form.dart';

import '../blocs/app_initialization/app_initialization.dart';
import '../blocs/auth/auth.dart';
import '../blocs/localization/app_localization.dart';
import '../blocs/localization/localization.dart';
import '../blocs/projects_beneficiary_downsync/project_beneficiaries_downsync.dart';
import '../data/local_store/no_sql/schema/app_configuration.dart';
import '../data/remote_client.dart';
import '../data/repositories/remote/bandwidth_check.dart';
import '../models/downsync/downsync.dart';
import '../models/entities/roles_type.dart';
import '../router/app_router.dart';
import '../router/authenticated_route_observer.dart';
import '../utils/environment_config.dart';
import '../utils/i18_key_constants.dart' as i18;
import '../utils/utils.dart';

@RoutePage()
class AuthenticatedPageWrapper extends StatelessWidget {
  AuthenticatedPageWrapper({super.key});

  final StreamController<bool> _drawerVisibilityController =
      StreamController.broadcast();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ShowcaseWidget(
      enableAutoScroll: true,
      builder: Builder(
        builder: (context) {
          return StreamBuilder<bool>(
            stream: _drawerVisibilityController.stream,
            builder: (context, snapshot) {
              final showDrawer = snapshot.data ?? false;

              return Portal(
                child: Scaffold(
                  backgroundColor: theme.colorTheme.generic.background,
                  appBar: AppBar(
                    backgroundColor: theme.colorTheme.primary.primary2,
                    foregroundColor: theme.colorTheme.paper.primary,
                    actions: showDrawer
                        ? [
                            BlocBuilder<BoundaryBloc, BoundaryState>(
                              builder: (ctx, state) {
                                final selectedBoundary = ctx.boundaryOrNull;

                                if (selectedBoundary == null) {
                                  return const SizedBox.shrink();
                                } else {
                                  LocalizationParams()
                                      .setCode([selectedBoundary.code!]);
                                  final boundaryName =
                                      AppLocalizations.of(context).translate(
                                    selectedBoundary.code ??
                                        i18.projectSelection.onProjectMapped,
                                  );

                                  final theme = Theme.of(context);

                                  return GestureDetector(
                                    onTap: () {
                                      ctx.router.replaceAll([
                                        BoundarySelectionRoute(),
                                      ]);
                                    },
                                    child: Container(
                                      padding:
                                          const EdgeInsets.only(right: spacer2),
                                      width: MediaQuery.of(context).size.width -
                                          60,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                boundaryName,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: theme
                                                      .colorTheme.paper.primary,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down_outlined,
                                              color: theme
                                                  .colorTheme.paper.primary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ]
                        : null,
                  ),
                  drawer: showDrawer ? drawerWidget(context) : null,
                  body: MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => ServiceBloc(
                          const ServiceEmptyState(),
                          serviceDataRepository: context
                              .repository<ServiceModel, ServiceSearchModel>(),
                        ),
                      ),

                      BlocProvider(
                        create: (_) => ServiceBloc(
                          const ServiceEmptyState(),
                          serviceDataRepository: context
                              .repository<ServiceModel, ServiceSearchModel>(),
                        ),
                      ),

                      // INFO : Need to add bloc of package Here
                      BlocProvider(
                        create: (context) {
                          final userId = context.loggedInUserUuid;

                          final isar = context.read<Isar>();
                          final bloc = SyncBloc(
                            isar: isar,
                            syncService: SyncService(),
                          );

                          if (!bloc.isClosed) {
                            bloc.add(SyncRefreshEvent(userId));
                          }
/* Every time when the user changes the screen
 this will refresh the data of sync count */
                          isar.opLogs
                              .filter()
                              .createdByEqualTo(userId)
                              .syncedUpEqualTo(false)
                              .watch()
                              .listen(
                            (event) {
                              if (!bloc.isClosed) {
                                triggerSyncRefreshEvent(bloc, userId, event);
                              }
                            },
                          );

                          isar.opLogs
                              .filter()
                              .createdByEqualTo(userId)
                              .syncedUpEqualTo(true)
                              .syncedDownEqualTo(false)
                              .watch()
                              .listen(
                            (event) {
                              if (!bloc.isClosed) {
                                triggerSyncRefreshEvent(bloc, userId, event);
                              }
                            },
                          );

                          return bloc;
                        },
                      ),
                      BlocProvider(
                        create: (_) => LocationBloc(location: Location())
                          ..add(const LoadLocationEvent()),
                      ),
                      BlocProvider(
                        create: (ctx) => BeneficiaryDownSyncBloc(
                          bandwidthCheckRepository: BandwidthCheckRepository(
                            DioClient().dio,
                            bandwidthPath:
                                envConfig.variables.checkBandwidthApiPath,
                          ),
                          individualLocalRepository: ctx.read<
                              LocalRepository<IndividualModel,
                                  IndividualSearchModel>>(),
                          downSyncRemoteRepository: ctx.read<
                              RemoteRepository<DownsyncModel,
                                  DownsyncSearchModel>>(),
                          downSyncLocalRepository: ctx.read<
                              LocalRepository<DownsyncModel,
                                  DownsyncSearchModel>>(),
                          householdLocalRepository: ctx.read<
                              LocalRepository<HouseholdModel,
                                  HouseholdSearchModel>>(),
                          householdMemberLocalRepository: ctx.read<
                              LocalRepository<HouseholdMemberModel,
                                  HouseholdMemberSearchModel>>(),
                          projectBeneficiaryLocalRepository: ctx.read<
                              LocalRepository<ProjectBeneficiaryModel,
                                  ProjectBeneficiarySearchModel>>(),
                          taskLocalRepository: ctx.read<
                              LocalRepository<TaskModel, TaskSearchModel>>(),
                          sideEffectLocalRepository: ctx.read<
                              LocalRepository<SideEffectModel,
                                  SideEffectSearchModel>>(),
                          referralLocalRepository: ctx.read<
                              LocalRepository<ReferralModel,
                                  ReferralSearchModel>>(),
                        ),
                      ),
                    ],
                    child: AutoRouter(
                      navigatorObservers: () => [
                        AuthenticatedRouteObserver(
                          onNavigated: () {
                            bool shouldShowDrawer;
                            switch (context.router.topRoute.name) {
                              case ProjectSelectionRoute.name:
                              case BoundarySelectionRoute.name:
                                shouldShowDrawer = false;
                                break;
                              default:
                                shouldShowDrawer = true;
                            }

                            _drawerVisibilityController.add(shouldShowDrawer);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void triggerSyncRefreshEvent(
      SyncBloc bloc, String userId, List<OpLog> event) {
    bloc.add(
      SyncRefreshEvent(
        userId,
        SyncServiceSingleton().entityMapper!.getSyncCount(event),
      ),
    );
  }

  Widget drawerWidget(BuildContext context) {
    final theme = Theme.of(context);

    var t = AppLocalizations.of(context);
    var tapCount = 0;

    final authBloc = context.read<AuthBloc>();
    bool isDistributor = authBloc.state != const AuthState.unauthenticated()
        ? context.loggedInUserRoles
            .where(
              (role) =>
                  role.code == RolesType.distributor.toValue() ||
                  role.code == RolesType.communityDistributor.toValue(),
            )
            .toList()
            .isNotEmpty
        : false;
    return Drawer(
      child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        return SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: theme.colorScheme.secondary.withOpacity(0.12),
                padding: const EdgeInsets.all(kPadding),
                child: SizedBox(
                  height: 280,
                  child: state.maybeMap(
                    authenticated: (value) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          value.userModel.userName.toString(),
                          style: theme.textTheme.displayMedium,
                        ),
                        Text(
                          value.userModel.mobileNumber.toString(),
                          style: theme.textTheme.labelSmall,
                        ),
                        if (value.userModel.permanentCity != null)
                          Text(
                            value.userModel.permanentCity.toString(),
                            style: theme.textTheme.displayMedium,
                          ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            context.router.push(UserQRDetailsRoute());
                          },
                          child: Container(
                            height: 155,
                            width: 155,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color:
                                    DigitTheme.instance.colorScheme.secondary,
                              ),
                            ),
                            child: QrImageView(
                              data: value.userModel.userName.toString() +
                                  Constants.pipeSeparator +
                                  context.loggedInUserUuid,
                              version: QrVersions.auto,
                              size: 150.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    orElse: () => const Offstage(),
                  ),
                ),
              ),
              DigitIconTile(
                title: AppLocalizations.of(context).translate(
                  i18.common.coreCommonHome,
                ),
                icon: Icons.home,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  context.router.replaceAll([HomeRoute()]);
                },
              ),
              // context.isDownSyncEnabled
              //     ? DigitIconTile(
              //         title: AppLocalizations.of(context).translate(
              //           i18.common.coreCommonViewDownloadedData,
              //         ),
              //         icon: Icons.download,
              //         onPressed: () {
              //           Navigator.of(context, rootNavigator: true).pop();
              //           context.router.push(const BeneficiariesReportRoute());
              //         },
              //       )
              //     : const Offstage(),
              DigitIconTile(
                title: AppLocalizations.of(context)
                    .translate(i18.common.coreCommonLogout),
                icon: Icons.logout,
                onPressed: () async {
                  final isConnected = await getIsConnected();
                  if (context.mounted) {
                    if (isConnected) {
                      DigitDialog.show(
                        context,
                        options: DigitDialogOptions(
                          titleText: t.translate(
                            i18.common.coreCommonWarning,
                          ),
                          titleIcon: Icon(
                            Icons.warning,
                            color: DigitTheme.instance.colorScheme.error,
                          ),
                          contentText: t.translate(
                            i18.login.logOutWarningMsg,
                          ),
                          primaryAction: DigitDialogActions(
                            label: t.translate(i18.common.coreCommonNo),
                            action: (ctx) => Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pop(true),
                          ),
                          secondaryAction: DigitDialogActions(
                            label: t.translate(i18.common.coreCommonYes),
                            action: (ctx) {
                              context
                                  .read<BoundaryBloc>()
                                  .add(const BoundaryResetEvent());
                              context
                                  .read<AuthBloc>()
                                  .add(const AuthLogoutEvent());
                              context.router.replaceAll([
                                LoginRoute(),
                              ]);
                            },
                          ),
                        ),
                      );
                    } else {
                      DigitToast.show(
                        context,
                        options: DigitToastOptions(
                          AppLocalizations.of(context).translate(
                            i18.login.noInternetError,
                          ),
                          true,
                          theme,
                        ),
                      );
                    }
                  }
                },
              ),
              PoweredByDigit(
                version: Constants().version,
              ),
            ],
          ),
        );
      }),
    );
  }

  List<SidebarItem>? buildLanguage(
      BackendInterface localizationModulesList,
      List<Languages>? languages,
      BuildContext context,
      AppConfiguration appConfig) {
    final state = context.read<AppInitializationBloc>().state as AppInitialized;
    return languages
        ?.map((e) => SidebarItem(
              title: e.label,
              onPressed: () {
                int index = languages.indexWhere(
                  (ele) => ele.value.toString() == e.value.toString(),
                );
                context
                    .read<LocalizationBloc>()
                    .add(LocalizationEvent.onLoadLocalization(
                      module:
                          "hcm-boundary-${envConfig.variables.hierarchyType.toLowerCase()},${localizationModulesList.interfaces.where((element) => element.type == Modules.localizationModule).map((e) => e.name.toString()).join(',')}",
                      tenantId: appConfig.tenantId ?? "default",
                      locale: e.value.toString(),
                      path: Constants.localizationApiPath,
                    ));

                context.read<LocalizationBloc>().add(
                      OnUpdateLocalizationIndexEvent(
                        index: index,
                        code: e.value.toString(),
                      ),
                    );
              },
              initiallySelected: getSelectedLanguage(
                  state,
                  languages.indexWhere(
                    (ele) => ele.value.toString() == e.value.toString(),
                  )),
            ))
        .toList();
  }
}
