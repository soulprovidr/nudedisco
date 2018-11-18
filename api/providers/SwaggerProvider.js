'use strict'

const { ServiceProvider } = require('@adonisjs/fold')

class SwaggerProvider extends ServiceProvider {
   /**
   * Attach context getter when all providers have
   * been registered
   *
   * @method boot
   *
   * @return {void}
   */
  boot () {
    const Config = this.app.use('Config');
    const Route = this.app.use('Route');
    const swagger = this.app.use('swagger-jsdoc');
    if (Config.get('swagger', false)) {
      // Get custom URL for Swagger specification, if defined.
      const specUrl = Config.get('swagger.specUrl', '/swagger.json')
      Route.get(specUrl, async ({ response }) => (
        swagger(Config.get('swagger.options', {}))
      ))
    }
  }
}

module.exports = SwaggerProvider
