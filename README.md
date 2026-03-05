# Esports Tournaments

Веб-приложение для управления киберспортивными турнирами.
База данных PostgreSQL + веб-интерфейс на Django.

## Стек
- Python 3.x
- Django
- PostgreSQL

## Возможности
- CRUD для турниров, команд, игроков, матчей
- Ролевая модель доступа (RBAC) на уровне БД: admin, operator, client
- Триггеры для автоматического ведения истории изменений
- Авторизация пользователей
- Детальная статистика

---

## Установка

### 1. Клонируй репозиторий

```bash
git clone https://github.com/Dwots/EsportsTournaments.git
cd EsportsTournaments
```

### 2. Создай виртуальное окружение

```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows
pip install -r requirements.txt
```

### 3. Подготовка PostgreSQL

#### Возможная ошибка: несовпадение версии сортировки (Collation)

Если при создании базы появляется ошибка:
> `создать базу данных не удалось: ОШИБКА: в базе-шаблоне "template1" обнаружено несоответствие версии правила сортировки`

Это значит, что ваша ОС обновилась, а PostgreSQL ещё не знает об этом.
Выполните эти команды **один раз**, и проблема исчезнет:

```bash
psql -U postgres -c "ALTER DATABASE template1 REFRESH COLLATION VERSION;"
psql -U postgres -c "ALTER DATABASE postgres REFRESH COLLATION VERSION;"
```

#### Создание базы данных

**Важно:** 
Сначала создайте схему (структура таблиц и триггеры), затем грузите данные.
Если сделать наоборот или запустить `python manage.py migrate` до загрузки данных,
возникнут конфликты (дублирование ключей, нарушение внешних ключей).

```bash
# Создаём пустую базу данных
createdb -U postgres esports_tournaments

# Загружаем структуру (таблицы, триггеры, индексы, роли)
psql -U postgres -d esports_tournaments -f sql/01_schema.sql

# Загружаем данные (игроки, команды, турниры, матчи, статистика)
# Этот шаг опциональный — можно пропустить, если хотите начать с пустой базы
psql -U postgres -d esports_tournaments -f sql/02_seed_data.sql
```

### 4. Настрой переменные окружения

```bash
cp .env.example .env
```

Откройте файл `.env` и заполните его.

#### Генерация SECRET_KEY

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Скопируйте результат и вставьте в поле `SECRET_KEY`.

#### Подключение к базе данных

У вас есть **два варианта**:

**Вариант А: Быстрый запуск (для локальной разработки)**

Используйте стандартного суперпользователя PostgreSQL.
Он имеет полные права и игнорирует все ограничения — идеально для тестирования.

```ini
DB_USER=postgres
DB_PASSWORD=ваш_пароль_от_postgres
DB_HOST=127.0.0.1
DB_PORT=5432
```

#### Вариант Б: Безопасный запуск (ролевая модель)

В базе данных реализована ролевая модель доступа (RBAC) с тремя уровнями:
- `administrator` / `esports_admin` — полные права на все таблицы
- `operator` / `esports_operator` — чтение всех таблиц + редактирование матчей, игроков, команд
- `client` / `esports_client` — только чтение

Группы ролей и права на таблицы уже прописаны в `01_schema.sql`
и применятся автоматически при загрузке схемы.

Однако **пользователей для входа** нужно создать вручную,
так как `pg_dump` одной базы данных не сохраняет глобальных пользователей PostgreSQL:

```bash
psql -U postgres << 'EOF'
-- Создаём пользователей
CREATE USER esports_admin WITH PASSWORD 'esports_admin_pass';
CREATE USER esports_operator WITH PASSWORD 'esports_operator_pass';
CREATE USER esports_client WITH PASSWORD 'esports_client_pass';

-- Привязываем их к группам ролей (наследование прав)
GRANT administrator TO esports_admin;
GRANT operator TO esports_operator;
GRANT client TO esports_client;
EOF
```

Затем укажите в `.env`:

```ini
DB_USER=esports_admin
DB_PASSWORD=esports_admin_pass
```

**Примечание:** `DB_USER` в `.env` — это технический пользователь для подключения Django к PostgreSQL.
Он НЕ связан с учётными записями на сайте (логин/пароль в админке).
Django-пользователи хранятся в таблице `auth_user` внутри самой базы данных.

### 5. Запуск проекта

```bash
cd esports_project
python manage.py migrate
python manage.py runserver
```

**Если вы загружали данные через `02_seed_data.sql`:**
Команда `createsuperuser` **не нужна** — суперпользователь уже восстановлен из дампа.

**Если вы начали с пустой базы (пропустили `02_seed_data.sql`):**
Создайте суперпользователя вручную:
```bash
python manage.py createsuperuser
```

### 6. Можно проверять

Откройте http://127.0.0.1:8000
