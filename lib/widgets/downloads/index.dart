import 'package:flutter/material.dart';

import 'package:hear2learn/app.dart';
import 'package:hear2learn/widgets/common/bottom_app_bar_player.dart';
import 'package:hear2learn/widgets/common/episode_tile.dart';
import 'package:hear2learn/widgets/common/placeholder_screen.dart';
import 'package:hear2learn/widgets/common/vertical_list_view.dart';
import 'package:hear2learn/widgets/common/with_fade_in_image.dart';
import 'package:hear2learn/widgets/episode/index.dart';
import 'package:hear2learn/helpers/episode.dart' as episodeHelpers;
import 'package:hear2learn/models/episode.dart';
import 'package:hear2learn/models/episode_download.dart';

class DownloadPage extends StatefulWidget {
  @override
  DownloadPageState createState() => DownloadPageState();
}

class DownloadPageState extends State<DownloadPage> {
  final App app = App();
  Future<List<Episode>> downloadsFuture;

  @override
  Widget build(BuildContext context) {
    EpisodeDownloadBean downloadModel = app.models['episode_download'];
    downloadsFuture = downloadModel.getAll().then((downloads) {
      return downloads.map((download) => download.getEpisodeFromDetails()).toList();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Downloads')
      ),
      body: FutureBuilder(
        future: downloadsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Episode>> snapshot) {
          if(!snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.data.isNotEmpty
            ? Container(
                child: VerticalListView(
                  children: snapshot.data.map((episode) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EpisodePage(episode: episode)),
                      );
                    },
                    child: EpisodeTile(
                      subtitle: episode.podcastTitle,
                      title: episode.title,
                      options: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await episodeHelpers.deleteEpisode(episode);
                          setState(() {
                            downloadsFuture = downloadModel.getAll().then((downloads) {
                              return downloads.map((download) => download.getEpisodeFromDetails()).toList();
                            });
                          });
                        },
                      ),
                    ),
                  )).toList(),
                ),
                padding: EdgeInsets.all(16.0),
              )
              : PlaceholderScreen(
                icon: Icons.get_app,
                subtitle: 'Download episodes and manage them here.',
                title: 'No downloads yet',
              );
        },
      ),
      bottomNavigationBar: BottomAppBarPlayer(),
    );
  }
}