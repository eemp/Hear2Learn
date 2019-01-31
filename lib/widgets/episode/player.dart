import 'package:flutter/material.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:hear2learn/app.dart';
import 'package:hear2learn/models/episode.dart';
import 'package:hear2learn/models/queued_episode.dart';
import 'package:hear2learn/redux/actions.dart';
import 'package:hear2learn/redux/selectors.dart';
import 'package:hear2learn/redux/state.dart';

class EpisodePlayer extends StatefulWidget {
  final Episode episode;

  const EpisodePlayer({
    Key key,
    this.episode,
  }) : super(key: key);

  @override
  EpisodePlayerState createState() => EpisodePlayerState();
}

class EpisodePlayerState extends State<EpisodePlayer> {
  final App app = App();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, QueuedEpisode>(
      converter: queuedEpisodeSelector,
      builder: (BuildContext context, QueuedEpisode queuedEpisode) {
        final bool canPlay = widget.episode.downloadPath != null;
        final bool isPlaying = queuedEpisode.isPlaying
          && widget.episode.url == queuedEpisode.episode?.url;
        final bool isQueued = widget.episode.url == queuedEpisode.episode?.url;
        //print('isPlaying = ${isPlaying.toString()}, queuedEpisode.isPlaying = ${queuedEpisode.isPlaying.toString()}, ${widget.episode.toString()}, ${queuedEpisode.episode.toString()}');
        final Duration duration = isQueued ? queuedEpisode.duration : null;
        final Function onPause = canPlay ? queuedEpisode.onPause : null;
        final Function onPlay = canPlay ? queuedEpisode.onPlay : null;
        final Duration position = isQueued ? queuedEpisode.position : null;

        return Column(
          children: <Widget>[
            Container(
              child: RichText(
                text: TextSpan(
                  text: widget.episode.title,
                  style: Theme.of(context).textTheme.subhead
                ),
                textAlign: TextAlign.center,
              ),
              margin: const EdgeInsets.only(bottom: 32.0),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    child: Text(
                      position.toString().contains('.')
                        ? position.toString().substring(0, position.toString().indexOf('.'))
                        : '0:00:00'
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      activeColor: Theme.of(context).accentColor,
                      min: 0.0,
                      max: duration?.inSeconds?.toDouble() ?? 0.0,
                      onChanged: isQueued ? (double value) {
                        seekInEpisode(Duration(seconds: value.toInt()));
                      } : null,
                      value: position?.inSeconds?.toDouble() ?? 0.0,
                    ),
                  ),
                  Container(
                    child: ( duration?.toString()?.indexOf('.') ?? -1 ) >= 0
                      ? Text(duration.toString().substring(0, duration.toString().indexOf('.')))
                      : const Text('0:00:00'),
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
              margin: const EdgeInsets.all(16.0),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    iconSize: 40.0,
                    onPressed: canPlay ? () {
                      seekInEpisode(Duration(seconds: position.inSeconds - 10));
                    } : null,
                  ),
                  RawMaterialButton(
                    shape: const CircleBorder(),
                    fillColor: canPlay ? Theme.of(context).accentColor : Colors.grey,
                    splashColor: Theme.of(context).splashColor,
                    highlightColor: Theme.of(context).accentColor.withOpacity(0.5),
                    elevation: 10.0,
                    highlightElevation: 5.0,
                    onPressed: canPlay ? () {
                      if(isPlaying) {
                        onPause();
                      }
                      else {
                        onPlay(widget.episode);
                      }
                    } : null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 35.0,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_30),
                    iconSize: 40.0,
                    onPressed: canPlay ? () {
                      seekInEpisode(Duration(seconds: position.inSeconds + 30));
                    } : null,
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
              margin: const EdgeInsets.only(bottom: 8.0),
            ),
          ],
        );
      },
    );
  }
}
