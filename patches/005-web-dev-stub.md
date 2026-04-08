# 005 — Web dev stub + Makefile

## Resumen

- Stub de audio y ajustes `kIsWeb` para desarrollo en navegador.
- **Makefile** en la raíz del player: imagen Docker, volúmenes y targets de test/analyze (valores por defecto alineados con Koel; overrides en `.env`).

## Repo hermano (backend Koel / Laravel)

El backend oficial es [koel/koel](https://github.com/koel/koel) (Laravel). Si mantienes un clon local del servidor junto a este repo, revisa en conjunto `web/index.html`, puertos (`:8000` API, `:8080` player vía Makefile) y cualquier bootstrap.

## Checklist tras cambios en `web/index.html` o Makefile

1. [ ] `flutter analyze` / `make test` según toques.
2. [ ] Si cambias puertos o nombres de contenedor, actualiza `.env.example` y documentación breve.
