class BandModel {
  final String? id;
  final String? name;
  final int? votes;

  BandModel({this.id, this.name, this.votes});

  factory BandModel.fromJson(Map<String, dynamic> json) {
    return BandModel(
      id: json.containsKey("id") && (json["id"] is String)
          ? json["id"]
          : 'no-id',
      name: json.containsKey("name") && (json["name"] is String)
          ? json["name"]
          : 'no-name',
      votes: json.containsKey("votes") ? int.tryParse('${json["votes"]}') : 0,
    );
  }
}
