module.exports = {
  watch: true,
  entry: {
    'albums.create': './resources/scripts/albums/create.js'
  },
  output: {
    filename: '[name].js',
    path: __dirname + '/public'
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        use: { loader: 'babel-loader' }
      }
    ]
  }
}