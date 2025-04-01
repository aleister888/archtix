// Desactivar cuentas de firefox
user_pref("identity.fxaccounts.enabled", false);
user_pref("identity.fxaccounts.toolbar.enabled", false);

// Permitir las extensiones instaladas por el script
user_pref("extensions.autoDisableScopes", 0);

// Desactivar pocket
user_pref("extensions.pocket.enabled", false);

// No autocompletar URLs
user_pref("browser.urlbar.autoFill", false);

// Permitir acceder a sitios no https:
user_pref("dom.security.https_only_mode", false);

// Arreglar problemas con algunos logins
user_pref("network.http.referer.XOriginPolicy", 0);

// Mostrar siempre los marcadores
user_pref("browser.toolbars.bookmarks.visibility", "always");

// Usar la barra de ventana del sistema
user_pref("browser.tabs.inTitlebar", 0);

// Mantener sesiones iniciadas
user_pref("browser.sessionstore.privacy_level", 0);
user_pref("privacy.clearOnShutdown.sessions", false);
user_pref("privacy.clearOnShutdown.cache", false);

// No borrar los datos automáticamente
user_pref("privacy.sanitize.sanitizeOnShutdown", false);
user_pref("privacy.sanitize.clearOnShutdown.hasMigratedToNewPrefs2", false);
user_pref("privacy.sanitize.cpd.hasMigratedToNewPrefs2", false);

// Pantalla de inicio
user_pref("browser.startup.homepage", "about:home");
user_pref("browser.startup.page", 1);
user_pref("browser.newtabpage.enabled", true);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", true);

// Desactivar notificaciones
user_pref("dom.push.enabled", false);

// Desactivar funciones experimentales
user_pref("browser.preferences.experimental", false);
user_pref("browser.preferences.experimental.hidden", true);

// Permitir UI personalizado
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Desactivar el baúl de contraseñas
user_pref("signon.rememberSignons", false);

// Usar el mismo buscador para las ventanas privadas
user_pref("browser.search.separatePrivateDefault", false);

// Implementar medidas anti-trazado
user_pref("privacy.resistFingerprinting", true);

// Desactivar LBing
user_pref("browser.urlbar.suggest.searches", false);

// Desactivar OCSP
user_pref("security.OCSP.enabled", 0);
user_pref("security.ssl.enable_ocsp_stapling", false);

// Permitir DRM
user_pref("media.eme.enabled", true);
