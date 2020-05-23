class Dashboard {
  Stats stats;

  Dashboard(
      {this.stats});

  Dashboard.fromJson(Map<String, dynamic> json) {
    stats = json['stats'] != null ? new Stats.fromJson(json['stats']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.stats != null) {
      data['stats'] = this.stats.toJson();
    }
    return data;
  }
}

class Stats {
  int visits;
  int confirmations;
  double rate;

  Stats(
      {this.visits, this.confirmations, this.rate});

  Stats.fromJson(Map<String, dynamic> json) {
    visits = json['visits'];
    confirmations = json['confirmations'];
    rate = json['rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['visits'] = this.visits;
    data['confirmations'] = this.confirmations;
    data['rate'] = this.rate;
    return data;
  }
}
