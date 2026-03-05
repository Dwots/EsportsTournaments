def user_role(request):
    """Добавляет информацию о роли пользователя во все шаблоны"""
    role = request.session.get('user_role', 'guest')
    return {
        'user_role': role,
        'is_client': role == 'client',
        'is_operator': role in ('operator', 'administrator'),
        'is_admin': role == 'administrator',
        'is_authenticated': request.session.get('is_authenticated', False),
    }