class ForecastModel {
  String rainChance;
  String forecastImgPath;

  ForecastModel(this.rainChance, this.forecastImgPath);

  @override
  String toString() {
    return '{ ${this.rainChance}, ${this.forecastImgPath} }';
  }
}
