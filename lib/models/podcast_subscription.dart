import 'dart:convert';
import 'package:hear2learn/models/podcast.dart';
import 'package:jaguar_orm/jaguar_orm.dart';
import 'package:uuid/uuid.dart';

part 'podcast_subscription.jorm.dart';

class PodcastSubscription {
  @IgnoreColumn()
  final Uuid uuid = Uuid();

  @PrimaryKey(length: 36)
  String id;
  bool isSubscribed;
  DateTime created;
  @Column(length: 0, isNullable: false)
  String details;
  @Column(length: 0, isNullable: false)
  String podcastId;
  @Column(length: 0, isNullable: false)
  String podcastUrl;

  PodcastSubscription({
    this.created,
    this.details,
    this.id,
    this.isSubscribed,
    this.podcastId,
    this.podcastUrl,
  }) {
    id ??= uuid.v4();
  }

  Podcast getPodcastFromDetails() {
    final Map<String, dynamic> decodedDetails = json.decode(details);
    return Podcast.fromJson(decodedDetails);
  }

  @override
  String toString() {
    return 'Id = $id: Created on ${created.toString()}, isSubscribed = ${isSubscribed.toString()}, podcastId: $podcastId, podcastUrl: $podcastUrl, details: $details';
  }
}

@GenBean()
class PodcastSubscriptionBean extends Bean<PodcastSubscription> with _PodcastSubscriptionBean {
  @override
  String get tableName => 'podcast_subscription';

  // ignore: always_specify_types
  PodcastSubscriptionBean(Adapter adapter) : super(adapter);
}
