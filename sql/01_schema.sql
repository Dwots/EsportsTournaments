--
-- PostgreSQL database dump
--

\restrict qe9inPJLImcB2tBKBwif0VF4cIoPZpwVNXeWDxtbt3ktl60pM5LbgpLoV2C1Og4

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: bracket_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.bracket_type_enum AS ENUM (
    'upper',
    'lower',
    'grand',
    'no_type'
);


ALTER TYPE public.bracket_type_enum OWNER TO postgres;

--
-- Name: stage_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.stage_type_enum AS ENUM (
    'playoff',
    'group'
);


ALTER TYPE public.stage_type_enum OWNER TO postgres;

--
-- Name: add_team_with_country(text, date, text, text, integer, text); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_team_with_country(IN p_team_name text, IN p_creation_date date, IN p_coach text, IN p_manager text, IN p_game_id integer, IN p_country_name text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_team_id INT;
    v_country_id INT;
BEGIN
    -- Получаем ID страны по имени
    SELECT id INTO v_country_id 
    FROM countries 
    WHERE country_name = p_country_name;
    
    IF v_country_id IS NULL THEN
        RAISE EXCEPTION 'Страна "%" не найдена', p_country_name;
    END IF;

    -- Создаём команду
    INSERT INTO teams (name, created_at, coach, manager, game_id)
    VALUES (p_team_name, p_creation_date, p_coach, p_manager, p_game_id)
    RETURNING id INTO v_team_id;

    -- Связываем со страной (изменено: team_countries → team_locations)
    INSERT INTO team_locations (team_id, country_id)
    VALUES (v_team_id, v_country_id);
    
    RAISE NOTICE 'Команда "%" успешно создана с ID = %, страна: %', 
        p_team_name, v_team_id, p_country_name;
END;
$$;


ALTER PROCEDURE public.add_team_with_country(IN p_team_name text, IN p_creation_date date, IN p_coach text, IN p_manager text, IN p_game_id integer, IN p_country_name text) OWNER TO postgres;

--
-- Name: generate_tournament_report(integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_tournament_report(p_tournament_id integer, p_report_type text DEFAULT 'full'::text) RETURNS TABLE(report_section text, report_data text)
    LANGUAGE plpgsql
    AS $_$
DECLARE
    v_sql TEXT;
    v_tournament_name TEXT;
    v_game_name TEXT;
    rec RECORD;
BEGIN
    -- Получаем информацию о турнире
    SELECT t.name, gl.name INTO v_tournament_name, v_game_name
    FROM tournaments t
    JOIN games_list gl ON gl.id = t.game_id
    WHERE t.id = p_tournament_id;
    
    IF v_tournament_name IS NULL THEN
        RAISE EXCEPTION 'Турнир с ID = % не найден', p_tournament_id;
    END IF;

    -- Заголовок отчёта
    report_section := 'HEADER';
    report_data := FORMAT('=== ОТЧЁТ ПО ТУРНИРУ: %s (%s) ===', v_tournament_name, v_game_name);
    RETURN NEXT;

    -- Таблица участников (standings)
    IF p_report_type IN ('full', 'standings') THEN
        report_section := 'STANDINGS';
        report_data := '--- Итоговая таблица ---';
        RETURN NEXT;
        
        v_sql := FORMAT($SQL$
            SELECT tp.place, t.name AS team_name, tp.earnings
            FROM tournament_participants tp
            JOIN teams t ON t.id = tp.team_id
            WHERE tp.tournament_id = %s
            ORDER BY tp.place NULLS LAST
        $SQL$, p_tournament_id);
        
        FOR rec IN EXECUTE v_sql LOOP
            report_section := 'STANDINGS';
            report_data := FORMAT('%s. %s - $%s', 
                COALESCE(rec.place::TEXT, '?'), rec.team_name, rec.earnings);
            RETURN NEXT;
        END LOOP;
    END IF;

    -- Матчи (все стадии турнира)
    IF p_report_type IN ('full', 'matches') THEN
        report_section := 'MATCHES';
        report_data := '--- Матчи турнира ---';
        RETURN NEXT;
        
        v_sql := FORMAT($SQL$
            SELECT 
                ts.name AS stage_name, 
                ts.stage_type::TEXT AS stage_type,
                t1.name AS team1, 
                t2.name AS team2, 
                tw.name AS winner
            FROM matches m
            JOIN tournament_stages ts ON ts.id = m.stage_id
            LEFT JOIN teams t1 ON t1.id = m.team1_id
            LEFT JOIN teams t2 ON t2.id = m.team2_id
            LEFT JOIN teams tw ON tw.id = m.winner_team_id
            WHERE ts.tournament_id = %s
            ORDER BY ts.stage_order, m.id
        $SQL$, p_tournament_id);
        
        FOR rec IN EXECUTE v_sql LOOP
            report_section := 'MATCHES';
            report_data := FORMAT('[%s - %s] %s vs %s → %s', 
                rec.stage_type, rec.stage_name, rec.team1, rec.team2, COALESCE(rec.winner, 'TBD'));
            RETURN NEXT;
        END LOOP;
    END IF;

    -- MVP статистика
    IF p_report_type IN ('full', 'stats') THEN
        report_section := 'TOP_PLAYERS';
        report_data := '--- Топ-5 игроков по KDA ---';
        RETURN NEXT;
        
        v_sql := FORMAT($SQL$
            SELECT 
                p.nickname, 
                t.name AS team_name,
                SUM(s.kills) AS kills, 
                SUM(s.deaths) AS deaths, 
                SUM(s.assists) AS assists,
                ROUND((SUM(s.kills) + SUM(s.assists))::NUMERIC / GREATEST(SUM(s.deaths), 1), 2) AS kda
            FROM player_game_stats s
            JOIN players p ON p.id = s.player_id
            JOIN player_teams pt ON pt.player_id = p.id
            JOIN teams t ON t.id = pt.team_id
            JOIN games g ON g.id = s.game_id
            JOIN matches m ON m.id = g.match_id
            JOIN tournament_stages ts ON ts.id = m.stage_id
            WHERE ts.tournament_id = %s
            GROUP BY p.id, p.nickname, t.name
            ORDER BY kda DESC
            LIMIT 5
        $SQL$, p_tournament_id);
        
        FOR rec IN EXECUTE v_sql LOOP
            report_section := 'TOP_PLAYERS';
            report_data := FORMAT('%s (%s) - KDA: %s (K:%s/D:%s/A:%s)', 
                rec.nickname, rec.team_name, rec.kda, rec.kills, rec.deaths, rec.assists);
            RETURN NEXT;
        END LOOP;
    END IF;

    RETURN;
END;
$_$;


ALTER FUNCTION public.generate_tournament_report(p_tournament_id integer, p_report_type text) OWNER TO postgres;

--
-- Name: get_player_tournament_stats(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_player_tournament_stats(p_tournament_id integer, p_player_id integer) RETURNS TABLE(total_kills bigint, total_deaths bigint, total_assists bigint, kda numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(SUM(s.kills),   0) AS total_kills,
        COALESCE(SUM(s.deaths),  0) AS total_deaths,
        COALESCE(SUM(s.assists), 0) AS total_assists,
        CASE
            WHEN COALESCE(SUM(s.deaths), 0) = 0
                THEN (COALESCE(SUM(s.kills), 0) + COALESCE(SUM(s.assists), 0))::NUMERIC
            ELSE ROUND(
                (COALESCE(SUM(s.kills), 0) + COALESCE(SUM(s.assists), 0))::NUMERIC 
                / SUM(s.deaths), 
                2
            )
        END AS kda
    FROM player_game_stats s
    JOIN games g ON g.id = s.game_id
    JOIN matches m ON m.id = g.match_id
    JOIN tournament_stages ts ON ts.id = m.stage_id  -- Изменено: playoff → tournament_stages
    WHERE ts.tournament_id = p_tournament_id
      AND s.player_id = p_player_id;
END;
$$;


ALTER FUNCTION public.get_player_tournament_stats(p_tournament_id integer, p_player_id integer) OWNER TO postgres;

--
-- Name: log_matches_changes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_matches_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user TEXT;
BEGIN
    BEGIN
        v_user := current_setting('app.current_user', true);
    EXCEPTION WHEN OTHERS THEN
        v_user := NULL;
    END;
    
    IF v_user IS NULL OR v_user = '' THEN
        v_user := current_user;
    END IF;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO matches_history (
            operation_type, operation_user,
            new_id, new_stage_id, new_team1_id, new_team2_id, 
            new_winner_team_id, new_match_date
        ) VALUES (
            'INSERT', v_user,
            NEW.id, NEW.stage_id, NEW.team1_id, NEW.team2_id,
            NEW.winner_team_id, NEW.match_date
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO matches_history (
            operation_type, operation_user,
            old_id, old_stage_id, old_team1_id, old_team2_id,
            old_winner_team_id, old_match_date,
            new_id, new_stage_id, new_team1_id, new_team2_id,
            new_winner_team_id, new_match_date
        ) VALUES (
            'UPDATE', v_user,
            OLD.id, OLD.stage_id, OLD.team1_id, OLD.team2_id,
            OLD.winner_team_id, OLD.match_date,
            NEW.id, NEW.stage_id, NEW.team1_id, NEW.team2_id,
            NEW.winner_team_id, NEW.match_date
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO matches_history (
            operation_type, operation_user,
            old_id, old_stage_id, old_team1_id, old_team2_id,
            old_winner_team_id, old_match_date
        ) VALUES (
            'DELETE', v_user,
            OLD.id, OLD.stage_id, OLD.team1_id, OLD.team2_id,
            OLD.winner_team_id, OLD.match_date
        );
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.log_matches_changes() OWNER TO postgres;

--
-- Name: log_players_changes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_players_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user TEXT;
BEGIN
    BEGIN
        v_user := current_setting('app.current_user', true);
    EXCEPTION WHEN OTHERS THEN
        v_user := NULL;
    END;
    
    IF v_user IS NULL OR v_user = '' THEN
        v_user := current_user;
    END IF;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO players_history (
            operation_type, operation_user,
            new_id, new_nickname, new_full_name, new_birthdate, 
            new_country_id, new_role, new_total_winnings, new_status
        ) VALUES (
            'INSERT', v_user,
            NEW.id, NEW.nickname, NEW.full_name, NEW.birthdate,
            NEW.country_id, NEW.role, NEW.total_winnings, NEW.status
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO players_history (
            operation_type, operation_user,
            old_id, old_nickname, old_full_name, old_birthdate,
            old_country_id, old_role, old_total_winnings, old_status,
            new_id, new_nickname, new_full_name, new_birthdate,
            new_country_id, new_role, new_total_winnings, new_status
        ) VALUES (
            'UPDATE', v_user,
            OLD.id, OLD.nickname, OLD.full_name, OLD.birthdate,
            OLD.country_id, OLD.role, OLD.total_winnings, OLD.status,
            NEW.id, NEW.nickname, NEW.full_name, NEW.birthdate,
            NEW.country_id, NEW.role, NEW.total_winnings, NEW.status
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO players_history (
            operation_type, operation_user,
            old_id, old_nickname, old_full_name, old_birthdate,
            old_country_id, old_role, old_total_winnings, old_status
        ) VALUES (
            'DELETE', v_user,
            OLD.id, OLD.nickname, OLD.full_name, OLD.birthdate,
            OLD.country_id, OLD.role, OLD.total_winnings, OLD.status
        );
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.log_players_changes() OWNER TO postgres;

--
-- Name: log_teams_changes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_teams_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user TEXT;
BEGIN
    BEGIN
        v_user := current_setting('app.current_user', true);
    EXCEPTION WHEN OTHERS THEN
        v_user := NULL;
    END;
    
    IF v_user IS NULL OR v_user = '' THEN
        v_user := current_user;
    END IF;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO teams_history (
            operation_type, operation_user,
            new_id, new_name, new_created_at, new_disbanded_at,
            new_coach, new_manager, new_total_earnings, new_game_id, new_captain_id
        ) VALUES (
            'INSERT', v_user,
            NEW.id, NEW.name, NEW.created_at, NEW.disbanded_at,
            NEW.coach, NEW.manager, NEW.total_earnings, NEW.game_id, NEW.captain_id
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO teams_history (
            operation_type, operation_user,
            old_id, old_name, old_created_at, old_disbanded_at,
            old_coach, old_manager, old_total_earnings, old_game_id, old_captain_id,
            new_id, new_name, new_created_at, new_disbanded_at,
            new_coach, new_manager, new_total_earnings, new_game_id, new_captain_id
        ) VALUES (
            'UPDATE', v_user,
            OLD.id, OLD.name, OLD.created_at, OLD.disbanded_at,
            OLD.coach, OLD.manager, OLD.total_earnings, OLD.game_id, OLD.captain_id,
            NEW.id, NEW.name, NEW.created_at, NEW.disbanded_at,
            NEW.coach, NEW.manager, NEW.total_earnings, NEW.game_id, NEW.captain_id
        );
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO teams_history (
            operation_type, operation_user,
            old_id, old_name, old_created_at, old_disbanded_at,
            old_coach, old_manager, old_total_earnings, old_game_id, old_captain_id
        ) VALUES (
            'DELETE', v_user,
            OLD.id, OLD.name, OLD.created_at, OLD.disbanded_at,
            OLD.coach, OLD.manager, OLD.total_earnings, OLD.game_id, OLD.captain_id
        );
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.log_teams_changes() OWNER TO postgres;

--
-- Name: register_team_for_tournament(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.register_team_for_tournament(IN p_tournament_id integer, IN p_team_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_current_count INT;
    v_max_teams INT;
    v_tournament_game_id INT;
    v_team_game_id INT;
BEGIN
    -- Проверяем существование турнира
    SELECT max_number_of_teams, game_id INTO v_max_teams, v_tournament_game_id
    FROM tournaments WHERE id = p_tournament_id;
    
    IF v_max_teams IS NULL THEN
        RAISE EXCEPTION 'Турнир с ID = % не найден', p_tournament_id;
    END IF;

    -- Проверяем существование команды и соответствие игры
    SELECT game_id INTO v_team_game_id FROM teams WHERE id = p_team_id;
    
    IF v_team_game_id IS NULL THEN
        RAISE EXCEPTION 'Команда с ID = % не найдена', p_team_id;
    END IF;
    
    IF v_team_game_id != v_tournament_game_id THEN
        RAISE EXCEPTION 'Команда играет в другую игру (team_game=%, tournament_game=%)', 
            v_team_game_id, v_tournament_game_id;
    END IF;

    -- Проверяем, не зарегистрирована ли уже
    IF EXISTS (SELECT 1 FROM tournament_participants 
               WHERE tournament_id = p_tournament_id AND team_id = p_team_id) THEN
        RAISE EXCEPTION 'Команда уже зарегистрирована на этот турнир';
    END IF;

    -- Проверяем лимит участников
    SELECT COUNT(*) INTO v_current_count 
    FROM tournament_participants WHERE tournament_id = p_tournament_id;
    
    IF v_current_count >= v_max_teams THEN
        RAISE EXCEPTION 'Турнир заполнен (% из % мест)', v_current_count, v_max_teams;
    END IF;

    -- Регистрируем команду
    INSERT INTO tournament_participants (tournament_id, team_id, earnings)
    VALUES (p_tournament_id, p_team_id, 0);
    
    RAISE NOTICE 'Команда ID=% успешно зарегистрирована на турнир ID=%', p_team_id, p_tournament_id;
END;
$$;


ALTER PROCEDURE public.register_team_for_tournament(IN p_tournament_id integer, IN p_team_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: esports_admin
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO esports_admin;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: esports_admin
--

ALTER TABLE public.auth_group ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: esports_admin
--

CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO esports_admin;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: esports_admin
--

ALTER TABLE public.auth_group_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: esports_admin
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO esports_admin;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: esports_admin
--

ALTER TABLE public.auth_permission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: esports_admin
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE public.auth_user OWNER TO esports_admin;

--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: esports_admin
--

CREATE TABLE public.auth_user_groups (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_groups OWNER TO esports_admin;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: esports_admin
--

ALTER TABLE public.auth_user_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: esports_admin
--

ALTER TABLE public.auth_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: esports_admin
--

CREATE TABLE public.auth_user_user_permissions (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_permissions OWNER TO esports_admin;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: esports_admin
--

ALTER TABLE public.auth_user_user_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: countries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    country_name text NOT NULL
);


ALTER TABLE public.countries OWNER TO postgres;

--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.countries_id_seq OWNER TO postgres;

--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: esports_admin
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO esports_admin;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: esports_admin
--

ALTER TABLE public.django_admin_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: esports_admin
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO esports_admin;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: esports_admin
--

ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: esports_admin
--

CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO esports_admin;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: esports_admin
--

ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: esports_admin
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO esports_admin;

--
-- Name: game_genres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.game_genres (
    id integer NOT NULL,
    genre_name text NOT NULL
);


ALTER TABLE public.game_genres OWNER TO postgres;

--
-- Name: game_genres_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.game_genres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.game_genres_id_seq OWNER TO postgres;

--
-- Name: game_genres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.game_genres_id_seq OWNED BY public.game_genres.id;


--
-- Name: game_genres_link; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.game_genres_link (
    game_id integer NOT NULL,
    genre_id integer NOT NULL
);


ALTER TABLE public.game_genres_link OWNER TO postgres;

--
-- Name: games; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games (
    id integer NOT NULL,
    match_id integer NOT NULL,
    game_number integer NOT NULL,
    map_id integer,
    team1_score integer DEFAULT 0,
    team2_score integer DEFAULT 0,
    winner_team_id integer,
    CONSTRAINT games_team1_score_check CHECK ((team1_score >= 0)),
    CONSTRAINT games_team2_score_check CHECK ((team2_score >= 0))
);


ALTER TABLE public.games OWNER TO postgres;

--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.games_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.games_id_seq OWNER TO postgres;

--
-- Name: games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.games_id_seq OWNED BY public.games.id;


--
-- Name: games_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.games_list (
    id integer NOT NULL,
    name text NOT NULL,
    has_heroes boolean DEFAULT false,
    has_towers boolean DEFAULT false
);


ALTER TABLE public.games_list OWNER TO postgres;

--
-- Name: games_list_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.games_list_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.games_list_id_seq OWNER TO postgres;

--
-- Name: games_list_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.games_list_id_seq OWNED BY public.games_list.id;


--
-- Name: heroes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.heroes (
    id integer NOT NULL,
    name text NOT NULL,
    game_id integer
);


ALTER TABLE public.heroes OWNER TO postgres;

--
-- Name: heroes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.heroes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.heroes_id_seq OWNER TO postgres;

--
-- Name: heroes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.heroes_id_seq OWNED BY public.heroes.id;


--
-- Name: maps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.maps (
    id integer NOT NULL,
    name text NOT NULL,
    game_id integer
);


ALTER TABLE public.maps OWNER TO postgres;

--
-- Name: maps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.maps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.maps_id_seq OWNER TO postgres;

--
-- Name: maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.maps_id_seq OWNED BY public.maps.id;


--
-- Name: matches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.matches (
    id integer NOT NULL,
    stage_id integer NOT NULL,
    team1_id integer,
    team2_id integer,
    winner_team_id integer,
    match_date date,
    CONSTRAINT matches_check CHECK (((team1_id IS NULL) OR (team2_id IS NULL) OR (team1_id <> team2_id))),
    CONSTRAINT matches_check1 CHECK (((winner_team_id IS NULL) OR (winner_team_id = team1_id) OR (winner_team_id = team2_id)))
);


ALTER TABLE public.matches OWNER TO postgres;

--
-- Name: matches_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.matches_history (
    history_id integer NOT NULL,
    operation_type character varying(10) NOT NULL,
    operation_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    operation_user text DEFAULT CURRENT_USER,
    old_id integer,
    old_stage_id integer,
    old_team1_id integer,
    old_team2_id integer,
    old_winner_team_id integer,
    old_match_date date,
    new_id integer,
    new_stage_id integer,
    new_team1_id integer,
    new_team2_id integer,
    new_winner_team_id integer,
    new_match_date date
);


ALTER TABLE public.matches_history OWNER TO postgres;

--
-- Name: matches_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.matches_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.matches_history_history_id_seq OWNER TO postgres;

--
-- Name: matches_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.matches_history_history_id_seq OWNED BY public.matches_history.history_id;


--
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.matches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.matches_id_seq OWNER TO postgres;

--
-- Name: matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.matches_id_seq OWNED BY public.matches.id;


--
-- Name: tournament_stages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_stages (
    id integer NOT NULL,
    tournament_id integer NOT NULL,
    name text NOT NULL,
    stage_type public.stage_type_enum NOT NULL,
    bracket_type public.bracket_type_enum DEFAULT 'no_type'::public.bracket_type_enum,
    stage_order integer NOT NULL
);


ALTER TABLE public.tournament_stages OWNER TO postgres;

--
-- Name: tournaments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournaments (
    id integer NOT NULL,
    name text NOT NULL,
    tier text,
    prize_pool integer,
    location text,
    max_number_of_teams integer,
    start_date date,
    end_date date,
    winner_team_id integer,
    game_id integer,
    CONSTRAINT tournaments_check CHECK ((start_date <= end_date)),
    CONSTRAINT tournaments_max_number_of_teams_check CHECK ((max_number_of_teams > 0)),
    CONSTRAINT tournaments_prize_pool_check CHECK ((prize_pool >= 0))
);


ALTER TABLE public.tournaments OWNER TO postgres;

--
-- Name: most_played_maps; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.most_played_maps AS
 SELECT m.name AS map_name,
    count(*) AS usage_count,
    g.map_id,
    t.name AS tournament_name,
    t.id AS tournament_id,
    (ts.stage_type)::text AS stage_type,
    gl.name AS game_name
   FROM (((((public.games g
     JOIN public.maps m ON ((g.map_id = m.id)))
     JOIN public.matches mtch ON ((mtch.id = g.match_id)))
     JOIN public.tournament_stages ts ON ((ts.id = mtch.stage_id)))
     JOIN public.tournaments t ON ((t.id = ts.tournament_id)))
     JOIN public.games_list gl ON ((gl.id = m.game_id)))
  GROUP BY g.map_id, m.name, t.name, t.id, ts.stage_type, gl.name
  ORDER BY (count(*)) DESC;


ALTER VIEW public.most_played_maps OWNER TO postgres;

--
-- Name: player_game_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_game_stats (
    id integer NOT NULL,
    game_id integer NOT NULL,
    player_id integer NOT NULL,
    hero_id integer,
    kills integer DEFAULT 0,
    deaths integer DEFAULT 0,
    assists integer DEFAULT 0,
    CONSTRAINT player_game_stats_assists_check CHECK ((assists >= 0)),
    CONSTRAINT player_game_stats_deaths_check CHECK ((deaths >= 0)),
    CONSTRAINT player_game_stats_kills_check CHECK ((kills >= 0))
);


ALTER TABLE public.player_game_stats OWNER TO postgres;

--
-- Name: player_game_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.player_game_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.player_game_stats_id_seq OWNER TO postgres;

--
-- Name: player_game_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.player_game_stats_id_seq OWNED BY public.player_game_stats.id;


--
-- Name: player_teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.player_teams (
    player_id integer NOT NULL,
    team_id integer NOT NULL,
    role text
);


ALTER TABLE public.player_teams OWNER TO postgres;

--
-- Name: players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players (
    id integer NOT NULL,
    nickname text NOT NULL,
    full_name text,
    birthdate date,
    role text,
    total_winnings integer DEFAULT 0,
    country_id integer,
    status text DEFAULT 'active'::text NOT NULL,
    CONSTRAINT players_status_check CHECK ((status = ANY (ARRAY['active'::text, 'inactive'::text]))),
    CONSTRAINT players_total_winnings_check CHECK ((total_winnings >= 0))
);


ALTER TABLE public.players OWNER TO postgres;

--
-- Name: players_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players_history (
    history_id integer NOT NULL,
    operation_type character varying(10) NOT NULL,
    operation_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    operation_user text DEFAULT CURRENT_USER,
    old_id integer,
    old_nickname text,
    old_full_name text,
    old_birthdate date,
    old_country_id integer,
    old_role text,
    old_total_winnings integer,
    old_status text,
    new_id integer,
    new_nickname text,
    new_full_name text,
    new_birthdate date,
    new_country_id integer,
    new_role text,
    new_total_winnings integer,
    new_status text
);


ALTER TABLE public.players_history OWNER TO postgres;

--
-- Name: players_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.players_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.players_history_history_id_seq OWNER TO postgres;

--
-- Name: players_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.players_history_history_id_seq OWNED BY public.players_history.history_id;


--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.players_id_seq OWNER TO postgres;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name text NOT NULL,
    created_at date,
    disbanded_at date,
    coach text,
    manager text,
    total_earnings integer DEFAULT 0,
    game_id integer,
    captain_id integer,
    CONSTRAINT teams_check CHECK (((created_at <= disbanded_at) OR (disbanded_at IS NULL))),
    CONSTRAINT teams_total_earnings_check CHECK ((total_earnings >= 0))
);


ALTER TABLE public.teams OWNER TO postgres;

--
-- Name: playoff_tree; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.playoff_tree AS
 WITH match_info AS (
         SELECT t.name AS tournament_name,
            t.id AS tournament_id,
            ts.stage_order,
            ts.name AS stage_name,
            (ts.bracket_type)::text AS bracket_type,
            (ts.stage_type)::text AS stage_type,
            m.id AS match_id,
            COALESCE(t1.name, 'TBD'::text) AS team1,
            COALESCE(t2.name, 'TBD'::text) AS team2,
            COALESCE(tw.name, '???'::text) AS winner_team,
            ( SELECT count(*) AS count
                   FROM public.games g
                  WHERE ((g.match_id = m.id) AND (g.winner_team_id = m.team1_id))) AS score1,
            ( SELECT count(*) AS count
                   FROM public.games g
                  WHERE ((g.match_id = m.id) AND (g.winner_team_id = m.team2_id))) AS score2
           FROM (((((public.matches m
             JOIN public.tournament_stages ts ON ((ts.id = m.stage_id)))
             JOIN public.tournaments t ON ((ts.tournament_id = t.id)))
             LEFT JOIN public.teams t1 ON ((t1.id = m.team1_id)))
             LEFT JOIN public.teams t2 ON ((t2.id = m.team2_id)))
             LEFT JOIN public.teams tw ON ((tw.id = m.winner_team_id)))
          WHERE (ts.stage_type = 'playoff'::public.stage_type_enum)
        ), numbered_matches AS (
         SELECT match_info.tournament_name,
            match_info.tournament_id,
            match_info.stage_order,
            match_info.stage_name,
            match_info.bracket_type,
            match_info.stage_type,
            match_info.match_id,
            match_info.team1,
            match_info.team2,
            match_info.winner_team,
            match_info.score1,
            match_info.score2,
            row_number() OVER (PARTITION BY match_info.tournament_id, match_info.stage_order ORDER BY match_info.match_id) AS match_number
           FROM match_info
        )
 SELECT tournament_name,
    tournament_id,
    stage_order,
    stage_name,
    bracket_type,
    match_id,
    match_number,
    team1,
    team2,
    winner_team,
    score1,
    score2,
    concat('Match #', match_number, ': ', team1, ' vs ', team2, ' → Winner: ', winner_team, ' [', score1, ':', score2, ']') AS match_summary
   FROM numbered_matches
  ORDER BY tournament_name, stage_order, match_number;


ALTER VIEW public.playoff_tree OWNER TO postgres;

--
-- Name: team_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_locations (
    team_id integer NOT NULL,
    country_id integer NOT NULL
);


ALTER TABLE public.team_locations OWNER TO postgres;

--
-- Name: teams_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams_history (
    history_id integer NOT NULL,
    operation_type character varying(10) NOT NULL,
    operation_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    operation_user text DEFAULT CURRENT_USER,
    old_id integer,
    old_name text,
    old_created_at date,
    old_disbanded_at date,
    old_coach text,
    old_manager text,
    old_total_earnings integer,
    old_game_id integer,
    old_captain_id integer,
    new_id integer,
    new_name text,
    new_created_at date,
    new_disbanded_at date,
    new_coach text,
    new_manager text,
    new_total_earnings integer,
    new_game_id integer,
    new_captain_id integer
);


ALTER TABLE public.teams_history OWNER TO postgres;

--
-- Name: teams_history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teams_history_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teams_history_history_id_seq OWNER TO postgres;

--
-- Name: teams_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teams_history_history_id_seq OWNED BY public.teams_history.history_id;


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teams_id_seq OWNER TO postgres;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: tournament_mvp; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.tournament_mvp AS
 SELECT t.id AS tournament_id,
    t.name AS tournament_name,
    p.id AS player_id,
    p.nickname,
    tm.name AS team_name,
    sum(s.kills) AS total_kills,
    sum(s.deaths) AS total_deaths,
    sum(s.assists) AS total_assists,
    count(g.id) AS games_played,
    round((((sum(s.kills) + sum(s.assists)))::numeric / (GREATEST(sum(s.deaths), (1)::bigint))::numeric), 2) AS kda
   FROM (((((((public.tournaments t
     JOIN public.tournament_stages ts ON ((ts.tournament_id = t.id)))
     JOIN public.matches m ON ((m.stage_id = ts.id)))
     JOIN public.games g ON ((g.match_id = m.id)))
     JOIN public.player_game_stats s ON ((s.game_id = g.id)))
     JOIN public.players p ON ((p.id = s.player_id)))
     LEFT JOIN public.player_teams pt ON ((pt.player_id = p.id)))
     LEFT JOIN public.teams tm ON ((tm.id = pt.team_id)))
  GROUP BY t.id, t.name, p.id, p.nickname, tm.name
  ORDER BY t.id, (round((((sum(s.kills) + sum(s.assists)))::numeric / (GREATEST(sum(s.deaths), (1)::bigint))::numeric), 2)) DESC;


ALTER VIEW public.tournament_mvp OWNER TO postgres;

--
-- Name: tournament_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tournament_participants (
    id integer NOT NULL,
    tournament_id integer NOT NULL,
    team_id integer NOT NULL,
    place integer,
    earnings integer DEFAULT 0,
    CONSTRAINT tournament_participants_earnings_check CHECK ((earnings >= 0)),
    CONSTRAINT tournament_participants_place_check CHECK ((place > 0))
);


ALTER TABLE public.tournament_participants OWNER TO postgres;

--
-- Name: tournament_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tournament_participants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournament_participants_id_seq OWNER TO postgres;

--
-- Name: tournament_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournament_participants_id_seq OWNED BY public.tournament_participants.id;


--
-- Name: tournament_stages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tournament_stages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournament_stages_id_seq OWNER TO postgres;

--
-- Name: tournament_stages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournament_stages_id_seq OWNED BY public.tournament_stages.id;


--
-- Name: tournaments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tournaments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tournaments_id_seq OWNER TO postgres;

--
-- Name: tournaments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tournaments_id_seq OWNED BY public.tournaments.id;


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: game_genres id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_genres ALTER COLUMN id SET DEFAULT nextval('public.game_genres_id_seq'::regclass);


--
-- Name: games id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);


--
-- Name: games_list id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_list ALTER COLUMN id SET DEFAULT nextval('public.games_list_id_seq'::regclass);


--
-- Name: heroes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.heroes ALTER COLUMN id SET DEFAULT nextval('public.heroes_id_seq'::regclass);


--
-- Name: maps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maps ALTER COLUMN id SET DEFAULT nextval('public.maps_id_seq'::regclass);


--
-- Name: matches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);


--
-- Name: matches_history history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches_history ALTER COLUMN history_id SET DEFAULT nextval('public.matches_history_history_id_seq'::regclass);


--
-- Name: player_game_stats id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_game_stats ALTER COLUMN id SET DEFAULT nextval('public.player_game_stats_id_seq'::regclass);


--
-- Name: players id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: players_history history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history ALTER COLUMN history_id SET DEFAULT nextval('public.players_history_history_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: teams_history history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams_history ALTER COLUMN history_id SET DEFAULT nextval('public.teams_history_history_id_seq'::regclass);


--
-- Name: tournament_participants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants ALTER COLUMN id SET DEFAULT nextval('public.tournament_participants_id_seq'::regclass);


--
-- Name: tournament_stages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_stages ALTER COLUMN id SET DEFAULT nextval('public.tournament_stages_id_seq'::regclass);


--
-- Name: tournaments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments ALTER COLUMN id SET DEFAULT nextval('public.tournaments_id_seq'::regclass);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: countries countries_country_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_country_name_key UNIQUE (country_name);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: game_genres game_genres_genre_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_genres
    ADD CONSTRAINT game_genres_genre_name_key UNIQUE (genre_name);


--
-- Name: game_genres_link game_genres_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_genres_link
    ADD CONSTRAINT game_genres_link_pkey PRIMARY KEY (game_id, genre_id);


--
-- Name: game_genres game_genres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_genres
    ADD CONSTRAINT game_genres_pkey PRIMARY KEY (id);


--
-- Name: games_list games_list_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_list
    ADD CONSTRAINT games_list_name_key UNIQUE (name);


--
-- Name: games_list games_list_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games_list
    ADD CONSTRAINT games_list_pkey PRIMARY KEY (id);


--
-- Name: games games_match_id_game_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_match_id_game_number_key UNIQUE (match_id, game_number);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: heroes heroes_name_game_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.heroes
    ADD CONSTRAINT heroes_name_game_id_key UNIQUE (name, game_id);


--
-- Name: heroes heroes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.heroes
    ADD CONSTRAINT heroes_pkey PRIMARY KEY (id);


--
-- Name: maps maps_name_game_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maps
    ADD CONSTRAINT maps_name_game_id_key UNIQUE (name, game_id);


--
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- Name: matches_history matches_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches_history
    ADD CONSTRAINT matches_history_pkey PRIMARY KEY (history_id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: player_game_stats player_game_stats_game_id_player_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_game_stats
    ADD CONSTRAINT player_game_stats_game_id_player_id_key UNIQUE (game_id, player_id);


--
-- Name: player_game_stats player_game_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_game_stats
    ADD CONSTRAINT player_game_stats_pkey PRIMARY KEY (id);


--
-- Name: player_teams player_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_teams
    ADD CONSTRAINT player_teams_pkey PRIMARY KEY (player_id, team_id);


--
-- Name: players_history players_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players_history
    ADD CONSTRAINT players_history_pkey PRIMARY KEY (history_id);


--
-- Name: players players_nickname_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_nickname_key UNIQUE (nickname);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: team_locations team_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_locations
    ADD CONSTRAINT team_locations_pkey PRIMARY KEY (team_id, country_id);


--
-- Name: teams_history teams_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams_history
    ADD CONSTRAINT teams_history_pkey PRIMARY KEY (history_id);


--
-- Name: teams teams_name_game_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_game_id_key UNIQUE (name, game_id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: tournament_participants tournament_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_pkey PRIMARY KEY (id);


--
-- Name: tournament_participants tournament_participants_tournament_id_team_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_tournament_id_team_id_key UNIQUE (tournament_id, team_id);


--
-- Name: tournament_stages tournament_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_stages
    ADD CONSTRAINT tournament_stages_pkey PRIMARY KEY (id);


--
-- Name: tournament_stages tournament_stages_tournament_id_name_stage_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_stages
    ADD CONSTRAINT tournament_stages_tournament_id_name_stage_type_key UNIQUE (tournament_id, name, stage_type);


--
-- Name: tournament_stages tournament_stages_tournament_id_stage_order_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_stages
    ADD CONSTRAINT tournament_stages_tournament_id_stage_order_key UNIQUE (tournament_id, stage_order);


--
-- Name: tournaments tournaments_name_game_id_start_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_name_game_id_start_date_key UNIQUE (name, game_id, start_date);


--
-- Name: tournaments tournaments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_pkey PRIMARY KEY (id);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_group_id_97559544; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_user_id_6a12ed8b; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_permission_id_1fbb5f2c; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_user_id_a95ead1b; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);


--
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: esports_admin
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: matches trg_matches_history; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_matches_history AFTER INSERT OR DELETE OR UPDATE ON public.matches FOR EACH ROW EXECUTE FUNCTION public.log_matches_changes();


--
-- Name: players trg_players_history; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_players_history AFTER INSERT OR DELETE OR UPDATE ON public.players FOR EACH ROW EXECUTE FUNCTION public.log_players_changes();


--
-- Name: teams trg_teams_history; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_teams_history AFTER INSERT OR DELETE OR UPDATE ON public.teams FOR EACH ROW EXECUTE FUNCTION public.log_teams_changes();


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: esports_admin
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: game_genres_link game_genres_link_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_genres_link
    ADD CONSTRAINT game_genres_link_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games_list(id) ON DELETE CASCADE;


--
-- Name: game_genres_link game_genres_link_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.game_genres_link
    ADD CONSTRAINT game_genres_link_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.game_genres(id) ON DELETE CASCADE;


--
-- Name: games games_map_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_map_id_fkey FOREIGN KEY (map_id) REFERENCES public.maps(id) ON DELETE SET NULL;


--
-- Name: games games_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id) ON DELETE CASCADE;


--
-- Name: games games_winner_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_winner_team_id_fkey FOREIGN KEY (winner_team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: heroes heroes_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.heroes
    ADD CONSTRAINT heroes_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games_list(id) ON DELETE CASCADE;


--
-- Name: maps maps_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.maps
    ADD CONSTRAINT maps_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games_list(id) ON DELETE CASCADE;


--
-- Name: matches matches_stage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_stage_id_fkey FOREIGN KEY (stage_id) REFERENCES public.tournament_stages(id) ON DELETE CASCADE;


--
-- Name: matches matches_team1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_team1_id_fkey FOREIGN KEY (team1_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: matches matches_team2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_team2_id_fkey FOREIGN KEY (team2_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: matches matches_winner_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_winner_team_id_fkey FOREIGN KEY (winner_team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: player_game_stats player_game_stats_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_game_stats
    ADD CONSTRAINT player_game_stats_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id) ON DELETE CASCADE;


--
-- Name: player_game_stats player_game_stats_hero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_game_stats
    ADD CONSTRAINT player_game_stats_hero_id_fkey FOREIGN KEY (hero_id) REFERENCES public.heroes(id) ON DELETE SET NULL;


--
-- Name: player_game_stats player_game_stats_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_game_stats
    ADD CONSTRAINT player_game_stats_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: player_teams player_teams_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_teams
    ADD CONSTRAINT player_teams_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE;


--
-- Name: player_teams player_teams_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.player_teams
    ADD CONSTRAINT player_teams_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: players players_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE SET NULL;


--
-- Name: team_locations team_locations_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_locations
    ADD CONSTRAINT team_locations_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE CASCADE;


--
-- Name: team_locations team_locations_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_locations
    ADD CONSTRAINT team_locations_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: teams teams_captain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_captain_id_fkey FOREIGN KEY (captain_id) REFERENCES public.players(id) ON DELETE SET NULL;


--
-- Name: teams teams_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games_list(id) ON DELETE SET NULL;


--
-- Name: tournament_participants tournament_participants_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: tournament_participants tournament_participants_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_participants
    ADD CONSTRAINT tournament_participants_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id) ON DELETE CASCADE;


--
-- Name: tournament_stages tournament_stages_tournament_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournament_stages
    ADD CONSTRAINT tournament_stages_tournament_id_fkey FOREIGN KEY (tournament_id) REFERENCES public.tournaments(id) ON DELETE CASCADE;


--
-- Name: tournaments tournaments_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games_list(id) ON DELETE SET NULL;


--
-- Name: tournaments tournaments_winner_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tournaments
    ADD CONSTRAINT tournaments_winner_team_id_fkey FOREIGN KEY (winner_team_id) REFERENCES public.teams(id) ON DELETE SET NULL;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO client;
GRANT USAGE ON SCHEMA public TO operator;
GRANT ALL ON SCHEMA public TO administrator;


--
-- Name: PROCEDURE add_team_with_country(IN p_team_name text, IN p_creation_date date, IN p_coach text, IN p_manager text, IN p_game_id integer, IN p_country_name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.add_team_with_country(IN p_team_name text, IN p_creation_date date, IN p_coach text, IN p_manager text, IN p_game_id integer, IN p_country_name text) TO operator;


--
-- Name: FUNCTION generate_tournament_report(p_tournament_id integer, p_report_type text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.generate_tournament_report(p_tournament_id integer, p_report_type text) TO operator;
GRANT ALL ON FUNCTION public.generate_tournament_report(p_tournament_id integer, p_report_type text) TO administrator;


--
-- Name: FUNCTION get_player_tournament_stats(p_tournament_id integer, p_player_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_player_tournament_stats(p_tournament_id integer, p_player_id integer) TO operator;
GRANT ALL ON FUNCTION public.get_player_tournament_stats(p_tournament_id integer, p_player_id integer) TO administrator;


--
-- Name: FUNCTION log_matches_changes(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.log_matches_changes() TO administrator;


--
-- Name: FUNCTION log_players_changes(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.log_players_changes() TO administrator;


--
-- Name: FUNCTION log_teams_changes(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.log_teams_changes() TO administrator;


--
-- Name: PROCEDURE register_team_for_tournament(IN p_tournament_id integer, IN p_team_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.register_team_for_tournament(IN p_tournament_id integer, IN p_team_id integer) TO operator;


--
-- Name: TABLE countries; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.countries TO client;
GRANT SELECT ON TABLE public.countries TO operator;
GRANT ALL ON TABLE public.countries TO administrator;


--
-- Name: SEQUENCE countries_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.countries_id_seq TO operator;
GRANT ALL ON SEQUENCE public.countries_id_seq TO administrator;


--
-- Name: TABLE game_genres; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.game_genres TO client;
GRANT SELECT ON TABLE public.game_genres TO operator;
GRANT ALL ON TABLE public.game_genres TO administrator;


--
-- Name: SEQUENCE game_genres_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.game_genres_id_seq TO operator;
GRANT ALL ON SEQUENCE public.game_genres_id_seq TO administrator;


--
-- Name: TABLE game_genres_link; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.game_genres_link TO client;
GRANT SELECT ON TABLE public.game_genres_link TO operator;
GRANT ALL ON TABLE public.game_genres_link TO administrator;


--
-- Name: TABLE games; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.games TO client;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.games TO operator;
GRANT ALL ON TABLE public.games TO administrator;


--
-- Name: SEQUENCE games_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.games_id_seq TO operator;
GRANT ALL ON SEQUENCE public.games_id_seq TO administrator;


--
-- Name: TABLE games_list; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.games_list TO client;
GRANT SELECT ON TABLE public.games_list TO operator;
GRANT ALL ON TABLE public.games_list TO administrator;


--
-- Name: SEQUENCE games_list_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.games_list_id_seq TO operator;
GRANT ALL ON SEQUENCE public.games_list_id_seq TO administrator;


--
-- Name: TABLE heroes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.heroes TO client;
GRANT SELECT ON TABLE public.heroes TO operator;
GRANT ALL ON TABLE public.heroes TO administrator;


--
-- Name: SEQUENCE heroes_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.heroes_id_seq TO operator;
GRANT ALL ON SEQUENCE public.heroes_id_seq TO administrator;


--
-- Name: TABLE maps; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.maps TO client;
GRANT SELECT ON TABLE public.maps TO operator;
GRANT ALL ON TABLE public.maps TO administrator;


--
-- Name: SEQUENCE maps_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.maps_id_seq TO operator;
GRANT ALL ON SEQUENCE public.maps_id_seq TO administrator;


--
-- Name: TABLE matches; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.matches TO client;
GRANT SELECT,INSERT,UPDATE ON TABLE public.matches TO operator;
GRANT ALL ON TABLE public.matches TO administrator;


--
-- Name: TABLE matches_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT ON TABLE public.matches_history TO operator;
GRANT ALL ON TABLE public.matches_history TO administrator;


--
-- Name: SEQUENCE matches_history_history_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.matches_history_history_id_seq TO operator;
GRANT ALL ON SEQUENCE public.matches_history_history_id_seq TO administrator;


--
-- Name: SEQUENCE matches_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.matches_id_seq TO operator;
GRANT ALL ON SEQUENCE public.matches_id_seq TO administrator;


--
-- Name: TABLE tournament_stages; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tournament_stages TO client;
GRANT SELECT,INSERT,UPDATE ON TABLE public.tournament_stages TO operator;
GRANT ALL ON TABLE public.tournament_stages TO administrator;


--
-- Name: TABLE tournaments; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tournaments TO client;
GRANT SELECT,INSERT,UPDATE ON TABLE public.tournaments TO operator;
GRANT ALL ON TABLE public.tournaments TO administrator;


--
-- Name: TABLE most_played_maps; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.most_played_maps TO client;
GRANT SELECT ON TABLE public.most_played_maps TO operator;
GRANT ALL ON TABLE public.most_played_maps TO administrator;


--
-- Name: TABLE player_game_stats; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.player_game_stats TO client;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.player_game_stats TO operator;
GRANT ALL ON TABLE public.player_game_stats TO administrator;


--
-- Name: SEQUENCE player_game_stats_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.player_game_stats_id_seq TO operator;
GRANT ALL ON SEQUENCE public.player_game_stats_id_seq TO administrator;


--
-- Name: TABLE player_teams; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.player_teams TO client;
GRANT SELECT,INSERT,UPDATE ON TABLE public.player_teams TO operator;
GRANT ALL ON TABLE public.player_teams TO administrator;


--
-- Name: TABLE players; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.players TO client;
GRANT SELECT,INSERT,UPDATE ON TABLE public.players TO operator;
GRANT ALL ON TABLE public.players TO administrator;


--
-- Name: TABLE players_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT ON TABLE public.players_history TO operator;
GRANT ALL ON TABLE public.players_history TO administrator;


--
-- Name: SEQUENCE players_history_history_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.players_history_history_id_seq TO operator;
GRANT ALL ON SEQUENCE public.players_history_history_id_seq TO administrator;


--
-- Name: SEQUENCE players_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.players_id_seq TO operator;
GRANT ALL ON SEQUENCE public.players_id_seq TO administrator;


--
-- Name: TABLE teams; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.teams TO client;
GRANT SELECT,INSERT,UPDATE ON TABLE public.teams TO operator;
GRANT ALL ON TABLE public.teams TO administrator;


--
-- Name: TABLE playoff_tree; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.playoff_tree TO client;
GRANT SELECT ON TABLE public.playoff_tree TO operator;
GRANT ALL ON TABLE public.playoff_tree TO administrator;


--
-- Name: TABLE team_locations; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.team_locations TO client;
GRANT SELECT,INSERT,UPDATE ON TABLE public.team_locations TO operator;
GRANT ALL ON TABLE public.team_locations TO administrator;


--
-- Name: TABLE teams_history; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT ON TABLE public.teams_history TO operator;
GRANT ALL ON TABLE public.teams_history TO administrator;


--
-- Name: SEQUENCE teams_history_history_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.teams_history_history_id_seq TO operator;
GRANT ALL ON SEQUENCE public.teams_history_history_id_seq TO administrator;


--
-- Name: SEQUENCE teams_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.teams_id_seq TO operator;
GRANT ALL ON SEQUENCE public.teams_id_seq TO administrator;


--
-- Name: TABLE tournament_mvp; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tournament_mvp TO client;
GRANT SELECT ON TABLE public.tournament_mvp TO operator;
GRANT ALL ON TABLE public.tournament_mvp TO administrator;


--
-- Name: TABLE tournament_participants; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.tournament_participants TO client;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.tournament_participants TO operator;
GRANT ALL ON TABLE public.tournament_participants TO administrator;


--
-- Name: SEQUENCE tournament_participants_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tournament_participants_id_seq TO operator;
GRANT ALL ON SEQUENCE public.tournament_participants_id_seq TO administrator;


--
-- Name: SEQUENCE tournament_stages_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tournament_stages_id_seq TO operator;
GRANT ALL ON SEQUENCE public.tournament_stages_id_seq TO administrator;


--
-- Name: SEQUENCE tournaments_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.tournaments_id_seq TO operator;
GRANT ALL ON SEQUENCE public.tournaments_id_seq TO administrator;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES TO operator;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO administrator;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO administrator;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO client;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO operator;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO administrator;


--
-- PostgreSQL database dump complete
--

\unrestrict qe9inPJLImcB2tBKBwif0VF4cIoPZpwVNXeWDxtbt3ktl60pM5LbgpLoV2C1Og4

