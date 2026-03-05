# tournaments/middleware.py
from django.db import connections
from .db_router import set_current_role


class CurrentUserMiddleware:
    """
    - Берёт роль из сессии и передаёт её в db_router через thread-local.
    - Ставит в PostgreSQL переменную app.current_user на нужном подключении.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # 1. Роль из сессии (если нет — считаем client)
        role = request.session.get('user_role', 'client')
        set_current_role(role) # прокидываем в роутер

        # 2. Определяем alias БД для бизнес-таблиц
        db_mapping = {
            'client': 'client',
            'operator': 'operator',
            'administrator': 'default',
        }
        db_alias = db_mapping.get(role, 'client')

        # 3. Ставим переменную app.current_user в Postgres на этом соединении
        try:
            conn = connections[db_alias]
            with conn.cursor() as cursor:
                cursor.execute("SET app.current_user = %s", [role])
        except Exception:
            # Не ломаем запрос, если что-то пошло не так
            pass

        response = self.get_response(request)
        return response