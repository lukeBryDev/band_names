import 'package:flutter/material.dart';

class BandModel {
  final String? id;
  final String? name;
  final int? votes;
  final Color? color;

  BandModel({this.id, this.name, this.votes, this.color});

  BandModel copyWith({
    String? id,
    String? name,
    int? votes,
    Color? color,
  }) {
    return BandModel(
      id: id ?? this.id,
      name: name ?? this.name,
      votes: votes ?? this.votes,
      color: color ?? this.color,
    );
  }

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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> band = {"name": name};
    if (id != null) band["id"] = id;
    if (votes != null) band["votes"] = votes;
    return band;
  }
}
