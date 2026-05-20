import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:play_on_app/model/response_model/series_model.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as match_model;
import 'package:play_on_app/model/response_model/highlight_model.dart' as highlight_model;
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/views/custom_background.dart/ad_banner_widget.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import '../../../view_model/after_controller/plan_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../widgets/admob_banner_widget.dart';

class SeriesDetailScreen extends StatefulWidget {
  const SeriesDetailScreen({super.key});

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Series series;

  @override
  void initState() {
    super.initState();
    series = Get.arguments as Series;
    _tabController = TabController(length: 5, vsync: this);

    // Fetch highlights for this series
    final homeController = Get.find<HomeController>();
    if (series.sId != null) {
      homeController.fetchHighlights(seriesId: series.sId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(String? date) {
    if (date == null) return "";
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWithOutImg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: Column(
          children: [
            /// WHITE DIVIDER LINE
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.white,
            ),

            /// 🔥 Banner
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                children: [
                  _buildMatchImage(
                    series.banner,
                    series.sport,
                    height: 180,
                    width: double.infinity,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (series.tournamentLogo != null && series.tournamentLogo!.isNotEmpty) ...[
                          Container(
                            height: 45,
                            width: 45,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Image.network(
                              series.tournamentLogo!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Text(series.title ?? "",
                            style: text18(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          "${_formatDate(series.startDate)} - ${_formatDate(series.endDate)}",
                          style: text12(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 🔥 SIMPLE TAB BAR
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.white,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(horizontal: 20),
              tabs: const [
                Tab(text: "Home"),
                Tab(text: "Upcoming"),
                Tab(text: "Highlights"),
                Tab(text: "Points"),
                Tab(text: "Teams"),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHomeTab(),
                  _buildUpcomingTab(),
                  _buildHighlightsTab(),
                  _buildPointsTab(),
                  _buildTeamsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= HOME TAB =================
  Widget _buildHomeTab() {
    final matches = series.fullMatches ?? [];

    final live = matches.where((m) => m.status == 'live').toList();
    final upcoming = matches.where((m) => m.status == 'upcoming').toList();
    final completed = matches.where((m) =>
    m.status == 'completed' || m.status == 'finished').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AdBannerWidget(padding: EdgeInsets.zero, height: 140, position: "series_top"),
        const SizedBox(height: 8),
        const AdMobBannerWidget(position: "series_top"),
        const SizedBox(height: 16),
        if (live.isNotEmpty) _buildHorizontalSection("Live Matches", live),
        if (upcoming.isNotEmpty) _buildHorizontalSection("Upcoming Matches", upcoming),
        if (completed.isNotEmpty) _buildHorizontalSection("Recent Results", completed),
      ],
    );
  }

  /// ================= UPCOMING =================
  Widget _buildUpcomingTab() {
    final matches = series.fullMatches
        ?.where((m) => m.status == 'upcoming')
        .toList() ??
        [];

    if (matches.isEmpty) {
      return Center(
        child: Text("No upcoming matches",
            style: text14(color: Colors.white60)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return const Column(
            children: [
              AdBannerWidget(position: "series_top"),
              SizedBox(height: 8),
              AdMobBannerWidget(position: "series_top"),
              SizedBox(height: 16),
            ],
          );
        }
        return _matchRow(matches[i - 1]);
      },
    );
  }

  /// ================= HIGHLIGHTS =================
  Widget _buildHighlightsTab() {
    final homeController = Get.find<HomeController>();

    return Obx(() {
      if (homeController.isSeriesHighlightsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final highlights = homeController.seriesHighlightList.toList();

      if (highlights.isEmpty) {
        return Center(
          child: Text("No highlights available",
              style: text14(color: Colors.white60)),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: highlights.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return const Column(
              children: [
                AdBannerWidget(position: "series_top"),
                SizedBox(height: 8),
                AdMobBannerWidget(position: "series_top"),
                SizedBox(height: 16),
              ],
            );
          }
          return _buildHighlightCard(highlights[i - 1]);
        },
      );
    });
  }

  Widget _buildHighlightCard(highlight_model.HighlightItem highlight) {
    final homeController = Get.find<HomeController>();
    
    String teamA = highlight.teamA?.name ?? highlight.matchId?.teamA ?? series.teamA ?? "";
    String teamB = highlight.teamB?.name ?? highlight.matchId?.teamB ?? series.teamB ?? "";
    String? teamALogo = highlight.teamA?.logo;
    String? teamBLogo = highlight.teamB?.logo;

    // Lookup names if they are IDs
    if (series.teams != null) {
      if (highlight.teamA == null) {
        final tA = series.teams!.firstWhereOrNull((t) => t.sId == teamA);
        if (tA != null) {
          teamA = tA.name ?? teamA;
          teamALogo ??= tA.logo;
        }
      }
      
      if (highlight.teamB == null) {
        final tB = series.teams!.firstWhereOrNull((t) => t.sId == teamB);
        if (tB != null) {
          teamB = tB.name ?? teamB;
          teamBLogo ??= tB.logo;
        }
      }
    }

    final displayTitle = (teamA.isNotEmpty && teamB.isNotEmpty) 
        ? "$teamA vs $teamB" 
        : (highlight.title ?? "Highlights");

    // Try to find the full match from HomeController to get logos/series
    final fullMatch = homeController.allMatches.firstWhereOrNull((m) => m.sId == highlight.matchId?.sId)
        ?? homeController.liveMatches.firstWhereOrNull((m) => m.sId == highlight.matchId?.sId)
        ?? homeController.seriesList.expand((s) => s.fullMatches ?? <match_model.Match>[]).firstWhereOrNull((m) => m.sId == highlight.matchId?.sId);
    
    // Create a match object for access checking and UI display
    final matchArg = fullMatch ?? (highlight.matchId != null ? match_model.Match(
      sId: highlight.matchId!.sId,
      isPremium: highlight.isPremium,
      status: highlight.matchId!.status,
      teamA: teamA,
      teamB: teamB,
      teamALogo: teamALogo,
      teamBLogo: teamBLogo,
      tournament: highlight.matchId!.tournament,
      sport: highlight.matchId!.sport,
      seriesId: highlight.seriesId?.sId ?? series.sId,
      videoUrl: highlight.videoUrl,
      thumbnail: highlight.thumbnail,
      title: highlight.title,
    ) : (highlight.seriesId != null || series.sId != null ? match_model.Match(
      sId: highlight.sId,
      isPremium: highlight.isPremium,
      seriesId: highlight.seriesId?.sId ?? series.sId,
      tournament: highlight.seriesId?.title ?? series.title,
      sport: highlight.seriesId?.sport ?? series.sport,
      teamA: teamA.isNotEmpty ? teamA : (highlight.seriesId?.title ?? series.title),
      teamB: teamB.isNotEmpty ? teamB : "Highlights",
      teamALogo: teamALogo,
      teamBLogo: teamBLogo,
      videoUrl: highlight.videoUrl,
      thumbnail: highlight.thumbnail,
      title: highlight.title,
    ) : null));

    final canWatch = Get.find<PlanController>().canWatchMatch(matchArg);
    return GestureDetector(
      onTap: () {
        if (matchArg != null) {
          homeController.handleProtectedAction(() {
            Get.toNamed("${AppRoutes.matchPlay}?mode=highlight", arguments: matchArg);
          }, checkAccess: true, hasPermission: canWatch);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: highlight.thumbnail ?? '',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(height: 180, color: Colors.white10),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: Colors.grey.withOpacity(0.2),
                      child: const Icon(Icons.play_circle_outline, color: Colors.white24, size: 50),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(canWatch ? Icons.play_arrow : Icons.lock_outline, color: Colors.white, size: 30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(highlight.duration),
                      style: text11(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: text16(fontWeight: FontWeight.bold),
                  ),
                  if (highlight.title != null && highlight.title != displayTitle)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        highlight.title!,
                        style: text13(color: AppColors.white60),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _teamMiniLogo(matchArg?.teamALogo),
                            const SizedBox(width: 4),
                            Flexible(child: Text(matchArg?.teamA ?? "", style: text12(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text("vs", style: text10(color: Colors.white38)),
                            ),
                            Flexible(child: Text(matchArg?.teamB ?? "", style: text12(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 4),
                            _teamMiniLogo(matchArg?.teamBLogo),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(String? duration) {
    if (duration == null) return "Highlights";
    try {
      final seconds = int.parse(duration);
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
    } catch (e) {
      return duration;
    }
  }

  Widget _teamMiniLogo(String? url) {
    return Container(
      height: 20,
      width: 20,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: CachedNetworkImage(
            imageUrl: url ?? "",
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) => const Icon(Icons.shield, size: 12, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsTab() {
    return Center(
      child: Text("Point Table Coming Soon",
          style: text14(color: Colors.white60)),
    );
  }

  Widget _buildTeamsTab() {
    final teams = series.teams ?? [];

    if (teams.isEmpty) {
      return Center(
        child: Text("No teams available",
            style: text14(color: Colors.white60)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return const Column(
            children: [
              AdBannerWidget(position: "series_top"),
              SizedBox(height: 8),
              AdMobBannerWidget(position: "series_top"),
              SizedBox(height: 16),
            ],
          );
        }
        final team = teams[i - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: team.logo != null && team.logo!.isNotEmpty
                    ? Image.network(
                        team.logo!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.shield,
                            color: Colors.white38,
                            size: 25),
                      )
                    : const Icon(Icons.shield,
                        color: Colors.white38, size: 25),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name ?? "",
                      style: text16(fontWeight: FontWeight.bold),
                    ),
                    if (team.country != null && team.country!.isNotEmpty)
                      Text(
                        team.country!,
                        style: text12(color: Colors.white60),
                      ),
                  ],
                ),
              ),
              // if (team.shortName != null && team.shortName!.isNotEmpty)
              //   Container(
              //     padding: const EdgeInsets.symmetric(
              //         horizontal: 8, vertical: 4),
              //     decoration: BoxDecoration(
              //       color: AppColors.primary.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(6),
              //       border: Border.all(
              //           color: AppColors.primary.withOpacity(0.3)),
              //     ),
              //     child: Text(
              //       team.shortName!,
              //       style: text12(
              //           color: AppColors.primary,
              //           fontWeight: FontWeight.bold),
              //     ),
              //   ),
            ],
          ),
        );
      },
    );
  }

  /// ================= SECTION =================
  Widget _buildHorizontalSection(String title, List<match_model.Match> matches) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: text16(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: matches.length,
            itemBuilder: (_, i) => _homeMatchCard(matches[i], screenWidth),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _homeMatchCard(match_model.Match match, double screenWidth) {
    return GestureDetector(
      onTap: () {
        if (match.status == 'upcoming') {
          Get.toNamed(AppRoutes.matchDetails, arguments: match);
        } else {
          Get.toNamed(AppRoutes.matchPlay, arguments: match);
        }
      },
      child: Container(
        width: screenWidth * 0.75, // Responsive width
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Match Banner
            Stack(
              children: [
                _buildMatchImage(
                  match.banner ?? match.thumbnail,
                  match.sport,
                  height: 140,
                  width: double.infinity,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                if (series.tournamentLogo != null && series.tournamentLogo!.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      height: 25,
                      width: 25,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Image.network(
                        series.tournamentLogo!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${match.teamA} vs ${match.teamB}",
                    style: text16(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(match.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _getStatusColor(match.status).withOpacity(0.5)),
                        ),
                        child: Text(
                          match.status?.toUpperCase() ?? "",
                          style: text10(
                            color: _getStatusColor(match.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_month, size: 14, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(match.matchDate),
                        style: text12(color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _matchRow(match_model.Match match) {
    return GestureDetector(
      onTap: () {
        if (match.status == 'upcoming') {
          Get.toNamed(AppRoutes.matchDetails, arguments: match);
        } else {
          Get.toNamed(AppRoutes.matchPlay, arguments: match);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            /// Thumbnail
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
              child: _buildMatchImage(
                match.thumbnail ?? match.banner,
                match.sport,
                width: 110,
                height: 75,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.sport?.toUpperCase() ?? "SPORTS",
                    style: text10(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${match.teamA} vs ${match.teamB}",
                    style: text14(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: Colors.white60),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(match.matchDate),
                        style: text12(color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'live':
        return Colors.red;
      case 'upcoming':
        return Colors.orange;
      case 'completed':
      case 'finished':
        return Colors.green;
      default:
        return Colors.white70;
    }
  }

  Widget _buildMatchImage(String? url, String? sport,
      {required double height, required double width, BorderRadius? borderRadius}) {
    final placeholder = _getSportPlaceholder(sport);

    Widget imageWidget;
    if (url == null || url.isEmpty) {
      imageWidget = Image.asset(
        placeholder,
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.network(
        url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          placeholder,
          height: height,
          width: width,
          fit: BoxFit.cover,
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  String _getSportPlaceholder(String? sport) {
    if (sport == null) return 'assets/auth/cri.png';
    switch (sport.toLowerCase()) {
      case 'football':
      case 'soccer':
        return 'assets/auth/football.png';
      case 'tennis':
        return 'assets/auth/tennis.jpg';
      case 'basketball':
        return 'assets/auth/basketball.jpg';
      default:
        return 'assets/auth/cri.png';
    }
  }
}
