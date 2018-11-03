module.exports = {
  watch: true,
  entry: {
    'AlbumCreateForm': './resources/components/AlbumCreateForm.js'
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