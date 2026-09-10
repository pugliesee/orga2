#include "../ejs.h"

void eliminar_publicaciones_del_feed_del_usuario(feed_t* feed, usuario_t* usuario) {

  bool encontre_nuevo_first = false;
  publicacion_t* actual = feed->first;
  publicacion_t* previa = NULL;

  while (actual != NULL) {

    publicacion_t* siguiente = actual->next;
    bool es_del_usuario_bloqueado = (actual->value->id_autor == usuario->id);

    if (!es_del_usuario_bloqueado) {
      
      // Esta publicación se queda en la lista
      if (!encontre_nuevo_first) {
        feed->first = actual;
        encontre_nuevo_first = true;
      }
      previa = actual;
    
    } else {

      // Esta publicación se elimina de la lista
      if (previa != NULL) {
        previa->next = siguiente;
      }

      free(actual);

    }

    actual = siguiente;

  }

  if (!encontre_nuevo_first) {
    feed->first = NULL;
  }

}

void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear) {
  
  // Bloqueamos al usuario y lo agregamos al listado
  usuario->bloqueados[usuario->cantBloqueados] = usuarioABloquear;
  usuario->cantBloqueados++;

  // Eliminamos del feed de mi user las publicaciones del otro
  eliminar_publicaciones_del_feed_del_usuario(usuario->feed, usuarioABloquear);

  // Lo mismo pero al revés
  eliminar_publicaciones_del_feed_del_usuario(usuarioABloquear->feed, usuario);

}
