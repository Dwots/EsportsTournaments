# tournaments/db_router.py
import threading

# Храним роль в thread-local
_role_state = threading.local()


def set_current_role(role: str):
    _role_state.role = role


def get_current_role() -> str:
    # По умолчанию считаем, что пользователь — client
    return getattr(_role_state, 'role', 'client')


class RoleBasedRouter:
    """
    Роутер, который:
    - для моделей приложения 'tournaments' выбирает БД по роли
    - для всех остальных моделей (sessions, auth, admin, ...) использует 'default'
    """

    managed_apps = {'tournaments'}

    def _db_for_role(self) -> str:
        role = get_current_role()
        if role == 'client':
            return 'client'
        if role == 'operator':
            return 'operator'
        if role == 'administrator':
            return 'default'
        return 'default'  # запасной вариант

    def db_for_read(self, model, **hints):
        # Наш роутинг — только для моделей приложения 'tournaments'
        if model._meta.app_label in self.managed_apps:
            return self._db_for_role()
        # Все системные приложения Django → только default
        return 'default'

    def db_for_write(self, model, **hints):
        if model._meta.app_label in self.managed_apps:
            return self._db_for_role()
        return 'default'

    def allow_relation(self, obj1, obj2, **hints):
        # Разрешаем любые отношения — Django сам разберётся
        return True

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        # Все миграции только в default
        return db == 'default'