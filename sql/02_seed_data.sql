--
-- PostgreSQL database dump
--

\restrict e7z4XC8xUNaaCt0BgtvKs1MqPxxh01AalAuRLXuJhCAP9UA6pr6LhDHJpX19jrE

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
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: esports_admin
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: esports_admin
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	admin	logentry
2	auth	permission
3	auth	group
4	auth	user
5	contenttypes	contenttype
6	sessions	session
7	tournaments	country
8	tournaments	game
9	tournaments	gamegenre
10	tournaments	gameslist
11	tournaments	hero
12	tournaments	map
13	tournaments	match
14	tournaments	matcheshistory
15	tournaments	player
16	tournaments	playergamestats
17	tournaments	playershistory
18	tournaments	playerteam
19	tournaments	team
20	tournaments	teamlocation
21	tournaments	teamshistory
22	tournaments	tournament
23	tournaments	tournamentparticipant
24	tournaments	tournamentstage
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: esports_admin
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add log entry	1	add_logentry
2	Can change log entry	1	change_logentry
3	Can delete log entry	1	delete_logentry
4	Can view log entry	1	view_logentry
5	Can add permission	2	add_permission
6	Can change permission	2	change_permission
7	Can delete permission	2	delete_permission
8	Can view permission	2	view_permission
9	Can add group	3	add_group
10	Can change group	3	change_group
11	Can delete group	3	delete_group
12	Can view group	3	view_group
13	Can add user	4	add_user
14	Can change user	4	change_user
15	Can delete user	4	delete_user
16	Can view user	4	view_user
17	Can add content type	5	add_contenttype
18	Can change content type	5	change_contenttype
19	Can delete content type	5	delete_contenttype
20	Can view content type	5	view_contenttype
21	Can add session	6	add_session
22	Can change session	6	change_session
23	Can delete session	6	delete_session
24	Can view session	6	view_session
25	Can add country	7	add_country
26	Can change country	7	change_country
27	Can delete country	7	delete_country
28	Can view country	7	view_country
29	Can add game	8	add_game
30	Can change game	8	change_game
31	Can delete game	8	delete_game
32	Can view game	8	view_game
33	Can add game genre	9	add_gamegenre
34	Can change game genre	9	change_gamegenre
35	Can delete game genre	9	delete_gamegenre
36	Can view game genre	9	view_gamegenre
37	Can add games list	10	add_gameslist
38	Can change games list	10	change_gameslist
39	Can delete games list	10	delete_gameslist
40	Can view games list	10	view_gameslist
41	Can add hero	11	add_hero
42	Can change hero	11	change_hero
43	Can delete hero	11	delete_hero
44	Can view hero	11	view_hero
45	Can add map	12	add_map
46	Can change map	12	change_map
47	Can delete map	12	delete_map
48	Can view map	12	view_map
49	Can add match	13	add_match
50	Can change match	13	change_match
51	Can delete match	13	delete_match
52	Can view match	13	view_match
53	Can add matches history	14	add_matcheshistory
54	Can change matches history	14	change_matcheshistory
55	Can delete matches history	14	delete_matcheshistory
56	Can view matches history	14	view_matcheshistory
57	Can add player	15	add_player
58	Can change player	15	change_player
59	Can delete player	15	delete_player
60	Can view player	15	view_player
61	Can add player game stats	16	add_playergamestats
62	Can change player game stats	16	change_playergamestats
63	Can delete player game stats	16	delete_playergamestats
64	Can view player game stats	16	view_playergamestats
65	Can add players history	17	add_playershistory
66	Can change players history	17	change_playershistory
67	Can delete players history	17	delete_playershistory
68	Can view players history	17	view_playershistory
69	Can add player team	18	add_playerteam
70	Can change player team	18	change_playerteam
71	Can delete player team	18	delete_playerteam
72	Can view player team	18	view_playerteam
73	Can add team	19	add_team
74	Can change team	19	change_team
75	Can delete team	19	delete_team
76	Can view team	19	view_team
77	Can add team location	20	add_teamlocation
78	Can change team location	20	change_teamlocation
79	Can delete team location	20	delete_teamlocation
80	Can view team location	20	view_teamlocation
81	Can add teams history	21	add_teamshistory
82	Can change teams history	21	change_teamshistory
83	Can delete teams history	21	delete_teamshistory
84	Can view teams history	21	view_teamshistory
85	Can add tournament	22	add_tournament
86	Can change tournament	22	change_tournament
87	Can delete tournament	22	delete_tournament
88	Can view tournament	22	view_tournament
89	Can add tournament participant	23	add_tournamentparticipant
90	Can change tournament participant	23	change_tournamentparticipant
91	Can delete tournament participant	23	delete_tournamentparticipant
92	Can view tournament participant	23	view_tournamentparticipant
93	Can add tournament stage	24	add_tournamentstage
94	Can change tournament stage	24	change_tournamentstage
95	Can delete tournament stage	24	delete_tournamentstage
96	Can view tournament stage	24	view_tournamentstage
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: esports_admin
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: esports_admin
--

COPY public.auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM stdin;
1	pbkdf2_sha256$1000000$WDU6VKcycU15qK5eN1wY8i$kvugimiR8FuEOT8NE/WrO6PP9QRWnlXL5YmBmS5Mfyc=	2025-12-09 10:58:15.558618+03	t	kirill				t	t	2025-12-09 10:25:52.825497+03
\.


--
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: esports_admin
--

COPY public.auth_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: esports_admin
--

COPY public.auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.countries (id, country_name) FROM stdin;
1	CIS
2	Europe
3	Asia
4	North America
5	South America
6	Saudi Arabia
7	Ukraine
8	Serbia
9	Russia
10	France
11	Germany
12	Brazil
13	China
14	Eastern Europe
15	Finland
16	Mongolia
17	Slovakia
18	Denmark
19	United States
20	Jordan
21	Bosnia and Herzegovina
22	North Macedonia
23	Belarus
24	Romania
25	Kosovo
26	United Arab Emirates
27	Japan
28	Indonesia
29	United Kingdom
30	Unknown
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: esports_admin
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: esports_admin
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2025-12-09 02:49:19.841609+03
2	auth	0001_initial	2025-12-09 02:49:19.87942+03
3	admin	0001_initial	2025-12-09 02:49:19.889985+03
4	admin	0002_logentry_remove_auto_add	2025-12-09 02:49:19.897635+03
5	admin	0003_logentry_add_action_flag_choices	2025-12-09 02:49:19.902472+03
6	contenttypes	0002_remove_content_type_name	2025-12-09 02:49:19.914077+03
7	auth	0002_alter_permission_name_max_length	2025-12-09 02:49:19.919657+03
8	auth	0003_alter_user_email_max_length	2025-12-09 02:49:19.924998+03
9	auth	0004_alter_user_username_opts	2025-12-09 02:49:19.929999+03
10	auth	0005_alter_user_last_login_null	2025-12-09 02:49:19.935216+03
11	auth	0006_require_contenttypes_0002	2025-12-09 02:49:19.936567+03
12	auth	0007_alter_validators_add_error_messages	2025-12-09 02:49:19.942285+03
13	auth	0008_alter_user_username_max_length	2025-12-09 02:49:19.948724+03
14	auth	0009_alter_user_last_name_max_length	2025-12-09 02:49:19.954913+03
15	auth	0010_alter_group_name_max_length	2025-12-09 02:49:19.96061+03
16	auth	0011_update_proxy_permissions	2025-12-09 02:49:19.96732+03
17	auth	0012_alter_user_first_name_max_length	2025-12-09 02:49:19.973419+03
18	sessions	0001_initial	2025-12-09 02:49:19.978351+03
19	tournaments	0001_initial	2025-12-09 02:49:19.987022+03
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: esports_admin
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
g5iqbxvyktqib7u137ob95vn6rexm5h3	.eJxVjssOwiAQRf-FtSE8Si0u3fsNDcwMFm2KAboy_ru06UK399x7Zt5sdGudxrVQHiOyC5Ps9Jt5B09aNoAPt9wTh7TUHD3fKvyghd8S0nw9un-CyZWprQ3ZANgrpQbdE2qwne3RQND6DEpjJ6QJXnrbGWxICBiEMAakhiC9GZp01-U0U9OlF2VXU25xLPs1WmoEV6m9WvNKny-LLUh4:1vSskG:jy2AP_nLMQm2L2G7VLqzk0TocCq-e21HmxxxfpqwtmU	2025-12-23 11:06:52.796425+03
\.


--
-- Data for Name: game_genres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.game_genres (id, genre_name) FROM stdin;
1	FPS
2	MOBA
3	Battle Royale
4	RTS
5	Fighting
\.


--
-- Data for Name: games_list; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.games_list (id, name, has_heroes, has_towers) FROM stdin;
1	Counter-Strike 2	f	f
2	Dota 2	t	t
\.


--
-- Data for Name: game_genres_link; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.game_genres_link (game_id, genre_id) FROM stdin;
1	1
2	2
\.


--
-- Data for Name: maps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.maps (id, name, game_id) FROM stdin;
1	Dust II	1
2	Mirage	1
3	Inferno	1
4	Ancient	1
5	Nuke	1
6	Train	1
7	Overpass	1
8	Default Dota 2 Map	2
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players (id, nickname, full_name, birthdate, role, total_winnings, country_id, status) FROM stdin;
1	NiKo	Nikola Kovač	1997-02-16	Rifler	1777583	21	active
2	TeSeS	René Madsen	2000-12-12	Rifler	794851	18	active
3	kyxsan	Damjan Stoilkovski	2000-05-26	In-game leader	322552	22	active
4	m0NESY	Илья Осипов	2005-05-01	AWPer	849098	9	active
5	kyousuke	Maksim Lukin	2008-01-30	Rifler	103763	9	active
6	b1t	Валерій Ваховський	2003-01-05	Rifler	1491055	7	active
7	Aleksib	Aleksi Virolainen	1997-03-30	In-game leader	874323	15	active
8	iM	Mihai Ivan	1999-07-29	Rifler	587236	24	active
9	w0nderful	Ігор Жданов	2004-12-14	AWPer	518649	7	active
10	makazze	Drin Shaqiri	2006-12-21	Rifler	124584	25	active
11	apEX	Dan Madesclaire	1993-02-22	In-game leader	2109778	10	active
12	ZywOo	Mathieu Herbaut	2000-11-09	AWPer	1628585	10	active
13	flameZ	Shahar Shushan	2003-06-22	Rifler	1046469	\N	active
14	mezii	William Merriman	1998-10-06	Rifler	921139	29	active
15	ropz	Robin Kool	1999-12-22	Rifler	2043952	\N	active
16	mouz_player1	Hans Müller	1999-03-15	In-game leader	85000	11	active
17	mouz_player2	Max Schmidt	2001-07-22	AWPer	65000	11	active
18	mouz_player3	Felix Weber	2000-11-10	Rifler	55000	11	active
19	mouz_player4	Leon Meyer	2002-05-18	Rifler	45000	11	active
20	mouz_player5	Paul Wagner	2003-01-25	Support	35000	11	active
21	3dmax_player1	Jean Dupont	1998-06-12	In-game leader	75000	10	active
22	3dmax_player2	Pierre Martin	2000-09-08	AWPer	60000	10	active
23	3dmax_player3	Luc Bernard	2001-12-03	Rifler	50000	10	active
24	3dmax_player4	Marc Dubois	2002-04-20	Rifler	40000	10	active
25	3dmax_player5	Antoine Petit	2003-08-15	Support	30000	10	active
26	faze_player1	John Smith	1997-02-14	In-game leader	95000	30	active
27	faze_player2	Mike Johnson	1999-05-21	AWPer	88000	30	active
28	faze_player3	Chris Brown	2000-08-30	Rifler	77000	30	active
29	faze_player4	David Wilson	2001-11-11	Rifler	66000	30	active
30	faze_player5	Robert Taylor	2002-03-07	Support	55000	30	active
31	furia_player1	João Silva	1998-01-10	In-game leader	70000	12	active
32	furia_player2	Carlos Santos	1999-04-25	AWPer	62000	12	active
33	furia_player3	Pedro Costa	2000-07-14	Rifler	54000	12	active
34	furia_player4	Lucas Oliveira	2001-10-02	Rifler	46000	12	active
35	furia_player5	André Souza	2002-12-28	Support	38000	12	active
36	spirit_cs1	Иван Петров	1999-02-18	In-game leader	80000	9	active
37	spirit_cs2	Дмитрий Смирнов	2000-05-09	AWPer	72000	9	active
38	spirit_cs3	Алексей Кузнецов	2001-08-22	Rifler	64000	9	active
39	spirit_cs4	Сергей Попов	2002-11-15	Rifler	56000	9	active
40	spirit_cs5	Андрей Иванов	2003-03-30	Support	48000	9	active
41	hotu_player1	Player One	1998-05-05	In-game leader	25000	30	active
42	hotu_player2	Player Two	1999-06-06	AWPer	20000	30	active
43	hotu_player3	Player Three	2000-07-07	Rifler	18000	30	active
44	hotu_player4	Player Four	2001-08-08	Rifler	16000	30	active
45	hotu_player5	Player Five	2002-09-09	Support	14000	30	active
46	inner_player1	Player Alpha	1997-01-01	In-game leader	30000	30	active
47	inner_player2	Player Beta	1998-02-02	AWPer	28000	30	active
48	inner_player3	Player Gamma	1999-03-03	Rifler	26000	30	active
49	inner_player4	Player Delta	2000-04-04	Rifler	24000	30	active
50	inner_player5	Player Epsilon	2001-05-05	Support	22000	30	active
51	gl_player1	Pro Gamer 1	1996-06-10	In-game leader	35000	30	active
52	gl_player2	Pro Gamer 2	1997-07-11	AWPer	32000	30	active
53	gl_player3	Pro Gamer 3	1998-08-12	Rifler	29000	30	active
54	gl_player4	Pro Gamer 4	1999-09-13	Rifler	26000	30	active
55	gl_player5	Pro Gamer 5	2000-10-14	Support	23000	30	active
56	gm_player1	Mate One	1998-03-20	In-game leader	28000	30	active
57	gm_player2	Mate Two	1999-04-21	AWPer	26000	30	active
58	gm_player3	Mate Three	2000-05-22	Rifler	24000	30	active
59	gm_player4	Mate Four	2001-06-23	Rifler	22000	30	active
60	gm_player5	Mate Five	2002-07-24	Support	20000	30	active
61	astralis_p1	Danish Pro 1	1996-01-15	In-game leader	90000	18	active
62	astralis_p2	Danish Pro 2	1997-02-16	AWPer	82000	18	active
63	astralis_p3	Danish Pro 3	1998-03-17	Rifler	74000	18	active
64	astralis_p4	Danish Pro 4	1999-04-18	Rifler	66000	18	active
65	astralis_p5	Danish Pro 5	2000-05-19	Support	58000	18	active
66	fluxo_p1	BR Player 1	1997-05-05	In-game leader	32000	12	active
67	fluxo_p2	BR Player 2	1998-06-06	AWPer	30000	12	active
68	fluxo_p3	BR Player 3	1999-07-07	Rifler	28000	12	active
69	fluxo_p4	BR Player 4	2000-08-08	Rifler	26000	12	active
70	fluxo_p5	BR Player 5	2001-09-09	Support	24000	12	active
71	m80_p1	NA Player 1	1996-10-10	In-game leader	38000	19	active
72	m80_p2	NA Player 2	1997-11-11	AWPer	36000	19	active
73	m80_p3	NA Player 3	1998-12-12	Rifler	34000	19	active
74	m80_p4	NA Player 4	1999-01-13	Rifler	32000	19	active
75	m80_p5	NA Player 5	2000-02-14	Support	30000	19	active
76	rooster_p1	Rooster 1	1998-04-10	In-game leader	18000	30	active
77	rooster_p2	Rooster 2	1999-05-11	AWPer	16000	30	active
78	rooster_p3	Rooster 3	2000-06-12	Rifler	14000	30	active
79	rooster_p4	Rooster 4	2001-07-13	Rifler	12000	30	active
80	rooster_p5	Rooster 5	2002-08-14	Support	10000	30	active
81	nrg_p1	Energy 1	1997-03-05	In-game leader	42000	19	active
82	nrg_p2	Energy 2	1998-04-06	AWPer	40000	19	active
83	nrg_p3	Energy 3	1999-05-07	Rifler	38000	19	active
84	nrg_p4	Energy 4	2000-06-08	Rifler	36000	19	active
85	nrg_p5	Energy 5	2001-07-09	Support	34000	19	active
86	legacy_p1	Legacy Pro 1	1996-08-20	In-game leader	27000	30	active
87	legacy_p2	Legacy Pro 2	1997-09-21	AWPer	25000	30	active
88	legacy_p3	Legacy Pro 3	1998-10-22	Rifler	23000	30	active
89	legacy_p4	Legacy Pro 4	1999-11-23	Rifler	21000	30	active
90	legacy_p5	Legacy Pro 5	2000-12-24	Support	19000	30	active
91	aurora_cs_p1	Aurora CS 1	1997-02-28	In-game leader	31000	30	active
92	aurora_cs_p2	Aurora CS 2	1998-03-29	AWPer	29000	30	active
93	aurora_cs_p3	Aurora CS 3	1999-04-30	Rifler	27000	30	active
94	aurora_cs_p4	Aurora CS 4	2000-05-31	Rifler	25000	30	active
95	aurora_cs_p5	Aurora CS 5	2001-06-01	Support	23000	30	active
96	mongolz_p1	Mongol Warrior 1	1998-07-15	In-game leader	44000	16	active
97	mongolz_p2	Mongol Warrior 2	1999-08-16	AWPer	42000	16	active
98	mongolz_p3	Mongol Warrior 3	2000-09-17	Rifler	40000	16	active
99	mongolz_p4	Mongol Warrior 4	2001-10-18	Rifler	38000	16	active
100	mongolz_p5	Mongol Warrior 5	2002-11-19	Support	36000	16	active
101	g2_p1	G2 Star 1	1996-04-12	In-game leader	87000	30	active
102	g2_p2	G2 Star 2	1997-05-13	AWPer	81000	30	active
103	g2_p3	G2 Star 3	1998-06-14	Rifler	75000	30	active
104	g2_p4	G2 Star 4	1999-07-15	Rifler	69000	30	active
105	g2_p5	G2 Star 5	2000-08-16	Support	63000	30	active
106	b8_cs_p1	Ukrainian Pro 1	1997-06-18	In-game leader	52000	7	active
107	b8_cs_p2	Ukrainian Pro 2	1998-07-19	AWPer	48000	7	active
108	b8_cs_p3	Ukrainian Pro 3	1999-08-20	Rifler	44000	7	active
109	b8_cs_p4	Ukrainian Pro 4	2000-09-21	Rifler	40000	7	active
110	b8_cs_p5	Ukrainian Pro 5	2001-10-22	Support	36000	7	active
111	ence_p1	Finnish Star 1	1996-11-25	In-game leader	78000	15	active
112	ence_p2	Finnish Star 2	1997-12-26	AWPer	72000	15	active
113	ence_p3	Finnish Star 3	1998-01-27	Rifler	66000	15	active
114	ence_p4	Finnish Star 4	1999-02-28	Rifler	60000	15	active
115	ence_p5	Finnish Star 5	2000-03-01	Support	54000	15	active
116	Yatoro	Ілля Мулярчук	2003-03-12	Carry	5912980	7	active
117	Larl	Денис Сигитов	2002-01-22	Solo Middle	1999000	9	active
118	rue	Александр Филин	2004-01-19	Support	393721	9	active
119	Collapse	Магомед Халилов	2002-02-25	Offlaner	5919645	9	active
120	panto	Никита Балаганин	1999-06-15	Support	201989	23	active
121	Satanic	Алан Галлямов	2007-10-13	Carry	348900	9	active
122	No[o]ne-	Володимир Міненко	1997-09-04	Solo Middle	2033295	7	active
123	DM	Дмитрий Дорохин	2000-01-08	Offlaner	919983	9	active
124	9Class	Эдгар Налтакян	2003-07-19	Support	475964	9	active
125	Dukalis	Андрей Куропаткин	2002-02-18	Support	449122	9	active
126	skiter	Oliver Lepko	1998-09-12	Carry	3199564	17	active
127	Malr1ne	Станислав Поторак	2004-09-17	Solo Middle	1180552	9	active
128	Cr1t-	Andreas Nielsen	1996-07-13	Support	3586968	18	active
129	Sneyking	Wu Jingjun	1995-05-03	Support	3556277	19	active
130	ATF	Ammar Al-Assaf	2005-04-03	Offlaner	1497411	20	active
131	xg_p1	Chinese Star 1	1998-05-10	Carry	120000	13	active
132	xg_p2	Chinese Star 2	1999-06-11	Solo Middle	110000	13	active
133	xg_p3	Chinese Star 3	2000-07-12	Offlaner	100000	13	active
134	xg_p4	Chinese Star 4	2001-08-13	Support	90000	13	active
135	xg_p5	Chinese Star 5	2002-09-14	Support	80000	13	active
136	tundra_p1	EU Pro 1	1997-03-08	Carry	95000	30	active
137	tundra_p2	EU Pro 2	1998-04-09	Solo Middle	88000	30	active
138	tundra_p3	EU Pro 3	1999-05-10	Offlaner	81000	30	active
139	tundra_p4	EU Pro 4	2000-06-11	Support	74000	30	active
140	tundra_p5	EU Pro 5	2001-07-12	Support	67000	30	active
141	heroic_d1	Hero Player 1	1998-02-14	Carry	45000	30	active
142	heroic_d2	Hero Player 2	1999-03-15	Solo Middle	42000	30	active
143	heroic_d3	Hero Player 3	2000-04-16	Offlaner	39000	30	active
144	heroic_d4	Hero Player 4	2001-05-17	Support	36000	30	active
145	heroic_d5	Hero Player 5	2002-06-18	Support	33000	30	active
146	tide_p1	Tide 1	1997-07-20	Carry	38000	30	active
147	tide_p2	Tide 2	1998-08-21	Solo Middle	36000	30	active
148	tide_p3	Tide 3	1999-09-22	Offlaner	34000	30	active
149	tide_p4	Tide 4	2000-10-23	Support	32000	30	active
150	tide_p5	Tide 5	2001-11-24	Support	30000	30	active
151	bb_p1	BB Star 1	1996-12-05	Carry	105000	9	active
152	bb_p2	BB Star 2	1997-01-06	Solo Middle	98000	9	active
153	bb_p3	BB Star 3	1998-02-07	Offlaner	91000	9	active
154	bb_p4	BB Star 4	1999-03-08	Support	84000	9	active
155	bb_p5	BB Star 5	2000-04-09	Support	77000	9	active
156	nigma_p1	Nigma Pro 1	1995-05-15	Carry	115000	26	active
157	nigma_p2	Nigma Pro 2	1996-06-16	Solo Middle	108000	26	active
158	nigma_p3	Nigma Pro 3	1997-07-17	Offlaner	101000	26	active
159	nigma_p4	Nigma Pro 4	1998-08-18	Support	94000	26	active
160	nigma_p5	Nigma Pro 5	1999-09-19	Support	87000	26	active
161	tl_d_c1	TL Dota Captain	1996-05-20	Carry	2400000	19	active
162	tl_d_p2	TL Dota Pro 2	1997-06-21	Solo Middle	2100000	19	active
163	tl_d_p3	TL Dota Pro 3	1998-07-22	Offlaner	1900000	30	active
164	tl_d_p4	TL Dota Pro 4	1999-08-23	Support	1600000	30	active
165	tl_d_p5	TL Dota Pro 5	2000-09-24	Support	1400000	30	active
166	wild_c1	Wildcard Captain	1995-04-10	Carry	40000	19	active
167	wild_p2	Wildcard Player 2	1996-05-11	Solo Middle	35000	19	active
168	wild_p3	Wildcard Player 3	1997-06-12	Offlaner	30000	19	active
169	wild_p4	Wildcard Player 4	1998-07-13	Support	25000	19	active
170	wild_p5	Wildcard Player 5	1999-08-14	Support	20000	19	active
171	yak_c1	Yakutou Captain	1996-03-12	Carry	30000	13	active
172	yak_p2	Yakutou Player 2	1997-04-13	Solo Middle	25000	13	active
173	yak_p3	Yakutou Player 3	1998-05-14	Offlaner	20000	13	active
174	yak_p4	Yakutou Player 4	1999-06-15	Support	15000	13	active
175	yak_p5	Yakutou Player 5	2000-07-16	Support	10000	13	active
176	boom_c1	BOOM Captain	1996-01-01	Carry	300000	28	active
177	boom_p2	BOOM Player 2	1997-02-02	Solo Middle	270000	28	active
178	boom_p3	BOOM Player 3	1998-03-03	Offlaner	240000	28	active
179	boom_p4	BOOM Player 4	1999-04-04	Support	200000	28	active
180	boom_p5	BOOM Player 5	2000-05-05	Support	180000	28	active
181	navi_d_c1	NaVi Dota Captain	1994-01-01	Carry	1300000	7	active
182	navi_d_p2	NaVi Dota Player 2	1995-02-02	Solo Middle	1200000	7	active
183	navi_d_p3	NaVi Dota Player 3	1996-03-03	Offlaner	1100000	7	active
184	navi_d_p4	NaVi Dota Player 4	1997-04-04	Support	1000000	7	active
185	navi_d_p5	NaVi Dota Player 5	1998-05-05	Support	900000	7	active
186	nemesis_c1	Nemesis Captain	1995-06-15	Carry	10000	30	active
187	nemesis_p2	Nemesis Player 2	1996-07-16	Solo Middle	8000	30	active
188	nemesis_p3	Nemesis Player 3	1997-08-17	Offlaner	7000	30	active
189	nemesis_p4	Nemesis Player 4	1998-09-18	Support	6000	30	active
190	nemesis_p5	Nemesis Player 5	1999-10-19	Support	4000	30	active
191	aurora_d_c1	Aurora D Captain	1995-01-10	Carry	220000	8	active
192	aurora_d_p2	Aurora D Player 2	1996-02-11	Solo Middle	200000	8	active
193	aurora_d_p3	Aurora D Player 3	1997-03-12	Offlaner	180000	8	active
194	aurora_d_p4	Aurora D Player 4	1998-04-13	Support	160000	8	active
195	aurora_d_p5	Aurora D Player 5	1999-05-14	Support	140000	8	active
197	test_admin	test_admin	1111-10-10	test_admin	100	20	active
198	TEST_OPERATOR	TEST_OPERATOR	1111-10-10	TEST_OPERATOR	1	9	active
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams (id, name, created_at, disbanded_at, coach, manager, total_earnings, game_id, captain_id) FROM stdin;
1	Team Falcons	2020-11-29	\N	zonic, trochu	Next, Mattéo Paganin, Xavier Roussac	1221340	1	\N
2	Natus Vincere	2012-11-04	\N	B1ad3	Mykola Grytsenko	11941825	1	\N
3	Team Vitality	2018-10-08	\N	XTQZZZ, MaT	Matthieu Péché	8515180	1	\N
4	MOUZ	2012-08-16	\N	sycrone, Xyp9x	Sabrina Szöllösi	6692430	1	\N
5	3DMAX	2009-04-29	\N	YouKnow, AlexTopGoal	Dylan Lo Vetere	733751	1	\N
6	FaZe Clan	2016-01-20	\N	NEO	Erik Anderson, Edward Han	9422447	1	\N
7	FURIA	2017-08-10	\N	sidde, Hepa, KrizzeN	guerri, Alexia Midori	2648423	1	\N
8	Team Spirit	2016-06-09	\N	hally	Vladislav Drozdov	4827591	1	\N
9	HOTU	2025-01-01	\N	t3hKing	Alexei Garvin	154000	1	\N
10	Inner Circle Esports	2025-01-01	\N	JStorm	Daniel Franks	172500	1	\N
11	GamerLegion	2025-01-01	\N	b0tMaster	Luna Leigh	210550	1	\N
12	Gentle Mates	2025-01-01	\N	Skyfire	Henrik Johansson	183700	1	\N
13	Astralis	2025-01-01	\N	devve	Kasper Hvidt	5432100	1	\N
14	Fluxo	2025-01-01	\N	FalleN	João Alves	860450	1	\N
15	M80	2025-01-01	\N	steel	Emily Carter	479300	1	\N
16	Rooster	2025-01-01	\N	Zeph	Tommy Nguyen	212000	1	\N
17	NRG	2025-01-01	\N	daps	Nick Johnson	1348000	1	\N
18	Legacy	2025-01-01	\N	HazR	Brandon Lin	95000	1	\N
19	Aurora Gaming	2022-03-14	\N	chopper	Svetlana Ivanova	430000	1	\N
20	The MongolZ	2018-05-01	\N	erkaSt	Ganbaatar Bat	670000	1	\N
21	G2 Esports	2015-02-01	\N	malek	Carlos Rodríguez	6407220	1	\N
22	B8	2023-03-01	\N	ZeroGravity	Andrii Diachenko	322500	1	\N
23	ENCE	2013-04-01	\N	sAw	Miikka Keränen	4862200	1	\N
24	HEROIC	2016-08-26	\N	TOBIZ	Sondre Børrestad	4169922	1	\N
25	Team Spirit	2015-12-06	\N	Silent	Korb3n	5991294	2	\N
26	PARIVISION	2025-01-08	\N	Astini	PHILadlephia, Kimi	2145569	2	\N
27	Team Falcons	2023-11-11	\N	Aui_2000	AfrOmoush, mAtéhaut, CHAOS	5951294	2	\N
28	Xtreme Gaming	2019-03-01	\N	xiao8	Fan, 叶孤城、	3089456	2	\N
29	Tundra Esports	2021-01-25	\N	MoonMeander	Th3RealJP	13458217	2	\N
30	HEROIC	2024-01-04	\N	kaffs	Babi	1123562	2	\N
31	Team Tidebound	2025-01-10	\N	Unknown	Unknown	0	2	\N
32	BB Team	2023-12-05	\N	Unknown	Unknown	0	2	\N
33	Nigma Galaxy	2022-04-18	\N	rmN-	Lukawa	4717453	2	\N
34	Team Liquid	2012-12-06	\N	Blitz, InsidiA	Steve Arhancet, Mohammed Morad	28500000	2	\N
35	Wildcard	2024-01-15	\N	SVG, ppd	Michael Chen	180000	2	\N
36	Yakutou Brothers	2023-08-10	\N	Yakult, Fenrir	Yakult	95000	2	\N
37	BOOM Esports	2016-09-01	\N	Tims, Benhur	Irwan Triwibowo	1350000	2	\N
38	Natus Vincere	2009-12-07	\N	Afoninje, SoNNeikO	Yevhen Zolotarov	13850000	2	\N
39	Team Nemesis	2024-12-01	\N	Coach_Nem	Unknown Manager	35000	2	\N
40	Aurora Gaming	2022-03-14	\N	G, kpii	DoublA, ReiNNNN	720000	2	\N
41	test	1111-10-10	\N	test	test	10	1	44
\.


--
-- Data for Name: tournaments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournaments (id, name, tier, prize_pool, location, max_number_of_teams, start_date, end_date, winner_team_id, game_id) FROM stdin;
1	The International 2025	The International	2881791	Germany, Hamburg	16	2025-09-04	2025-09-14	27	2
2	ESL Pro League Season 22	Tier 1	400000	Stockholm	24	2025-09-28	2025-10-12	3	1
4	test	test	100	test	19	1111-10-10	1111-10-11	23	1
5	test_admin	test_admin	33	test_admin	13	1111-12-13	1111-12-13	25	2
\.


--
-- Data for Name: tournament_stages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_stages (id, tournament_id, name, stage_type, bracket_type, stage_order) FROM stdin;
1	2	Stage 1	group	no_type	1
2	2	Stage 2	group	no_type	2
3	2	Quarterfinals	playoff	no_type	3
4	2	Semifinals	playoff	no_type	4
5	2	Grand Final	playoff	no_type	5
6	2	Third Place Match	playoff	no_type	6
7	1	Standings	group	no_type	1
8	1	Upper Bracket Quarterfinals	playoff	upper	2
9	1	Lower Bracket Round 1	playoff	lower	3
10	1	Upper Bracket Semifinals	playoff	upper	4
11	1	Lower Bracket Quarterfinals	playoff	lower	5
12	1	Lower Bracket Semifinal	playoff	lower	6
13	1	Upper Bracket Final	playoff	upper	7
14	1	Lower Bracket Final	playoff	lower	8
15	1	Grand Final	playoff	grand	9
\.


--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.matches (id, stage_id, team1_id, team2_id, winner_team_id, match_date) FROM stdin;
1	3	8	6	6	2025-10-01
2	3	7	3	3	2025-10-01
3	3	4	2	4	2025-10-02
4	3	5	1	1	2025-10-02
5	4	6	3	3	2025-10-05
6	4	4	1	1	2025-10-06
7	5	3	1	3	2025-10-10
8	6	4	6	4	2025-10-09
9	8	28	29	28	2025-09-04
10	8	26	30	26	2025-09-04
11	8	31	27	27	2025-09-05
12	8	32	33	32	2025-09-05
13	10	28	26	26	2025-09-07
14	10	27	32	27	2025-09-07
15	9	29	30	30	2025-09-08
16	9	31	33	33	2025-09-08
17	11	32	30	32	2025-09-09
18	11	28	33	28	2025-09-09
19	12	32	28	28	2025-09-10
20	13	26	27	27	2025-09-11
21	14	26	28	28	2025-09-12
22	15	27	28	27	2025-09-14
23	1	9	7	9	2025-09-28
24	1	9	22	9	2025-09-28
25	1	9	23	9	2025-09-29
26	1	10	5	10	2025-09-28
27	1	10	11	10	2025-09-28
28	1	10	12	10	2025-09-29
29	1	5	16	5	2025-09-28
30	1	5	24	5	2025-09-29
31	1	5	23	5	2025-09-29
32	1	11	17	11	2025-09-28
33	1	11	13	11	2025-09-29
34	1	11	22	11	2025-09-29
35	1	12	24	12	2025-09-28
36	1	12	21	12	2025-09-28
37	1	12	18	12	2025-09-29
38	1	13	14	13	2025-09-28
39	1	13	23	23	2025-09-28
40	1	13	24	13	2025-09-29
41	1	13	18	13	2025-09-29
42	1	7	14	7	2025-09-28
43	1	7	18	7	2025-09-28
44	1	7	15	7	2025-09-29
45	1	7	22	7	2025-09-29
46	1	21	16	21	2025-09-28
47	1	21	22	22	2025-09-28
48	1	21	14	21	2025-09-29
49	1	21	23	21	2025-09-29
50	1	22	18	22	2025-09-28
51	1	23	15	23	2025-09-28
52	1	18	17	18	2025-09-28
53	1	14	17	14	2025-09-29
54	1	24	15	24	2025-09-28
55	1	15	16	15	2025-09-29
56	2	8	10	8	2025-10-01
57	2	8	9	8	2025-10-01
58	2	8	21	8	2025-10-02
59	2	1	13	1	2025-10-01
60	2	1	2	1	2025-10-01
61	2	1	4	1	2025-10-02
62	2	4	11	4	2025-10-01
63	2	4	12	4	2025-10-01
64	2	4	5	4	2025-10-02
65	2	3	12	12	2025-10-01
66	2	3	11	3	2025-10-01
67	2	3	9	3	2025-10-02
68	2	3	21	3	2025-10-02
69	2	7	5	7	2025-10-01
70	2	7	21	21	2025-10-01
71	2	7	10	7	2025-10-02
72	2	7	19	7	2025-10-02
73	2	2	19	2	2025-10-01
74	2	2	5	5	2025-10-01
75	2	2	9	2	2025-10-02
76	2	2	20	2	2025-10-02
77	2	5	6	5	2025-10-01
78	2	5	21	5	2025-10-02
79	2	6	21	6	2025-10-01
80	2	6	13	6	2025-10-01
81	2	6	10	6	2025-10-02
82	2	6	19	6	2025-10-02
83	2	19	13	19	2025-10-01
84	2	19	12	19	2025-10-02
85	2	20	11	20	2025-10-01
86	2	20	12	20	2025-10-02
87	2	9	20	9	2025-10-01
88	2	10	20	10	2025-10-01
89	7	28	40	28	2025-09-04
90	7	28	25	28	2025-09-04
91	7	28	27	28	2025-09-05
92	7	28	31	28	2025-09-05
93	7	32	33	33	2025-09-04
94	7	32	37	32	2025-09-04
95	7	32	38	32	2025-09-05
96	7	32	40	32	2025-09-05
97	7	32	26	32	2025-09-06
98	7	31	38	31	2025-09-04
99	7	31	34	31	2025-09-04
100	7	31	26	31	2025-09-05
101	7	31	27	31	2025-09-06
102	7	40	35	40	2025-09-04
103	7	40	36	40	2025-09-05
104	7	40	25	40	2025-09-06
105	7	27	39	27	2025-09-04
106	7	27	29	27	2025-09-04
107	7	27	34	27	2025-09-05
108	7	26	30	26	2025-09-04
109	7	26	33	26	2025-09-04
110	7	26	25	26	2025-09-05
111	7	30	38	38	2025-09-04
112	7	30	37	30	2025-09-05
113	7	30	35	30	2025-09-05
114	7	30	29	30	2025-09-06
115	7	34	37	34	2025-09-04
116	7	34	33	34	2025-09-05
117	7	34	36	34	2025-09-06
118	7	25	35	25	2025-09-04
119	7	25	29	25	2025-09-05
120	7	35	39	35	2025-09-05
121	7	35	37	35	2025-09-06
122	7	29	36	29	2025-09-04
123	7	29	38	29	2025-09-05
124	7	36	39	36	2025-09-04
125	7	36	33	36	2025-09-05
126	7	33	38	33	2025-09-06
127	7	37	39	37	2025-09-05
128	7	38	29	29	2025-09-05
\.


--
-- Data for Name: games; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.games (id, match_id, game_number, map_id, team1_score, team2_score, winner_team_id) FROM stdin;
1	1	1	2	9	13	6
2	1	2	5	5	13	6
3	2	1	7	13	9	7
4	2	2	3	7	13	3
5	2	3	5	7	13	3
6	3	1	4	14	16	2
7	3	2	3	13	8	4
8	3	3	6	13	4	4
9	4	1	3	13	9	5
10	4	2	4	9	13	1
11	4	3	5	13	16	1
12	5	1	2	22	20	6
13	5	2	3	9	13	3
14	5	3	1	8	13	3
15	6	1	3	13	16	1
16	6	2	4	7	13	1
17	7	1	3	13	10	3
18	7	2	6	13	9	3
19	7	3	1	13	5	3
20	8	1	4	13	7	4
21	8	2	7	13	10	4
22	9	1	8	1	0	28
23	9	2	8	1	0	28
24	10	1	8	1	0	26
25	10	2	8	1	0	26
26	11	1	8	0	1	27
27	11	2	8	0	1	27
28	12	1	8	1	0	32
29	12	2	8	0	1	33
30	12	3	8	1	0	32
31	13	1	8	0	1	26
32	13	2	8	0	1	26
33	14	1	8	1	0	27
34	14	2	8	0	1	32
35	14	3	8	1	0	27
36	15	1	8	0	1	30
37	15	2	8	0	1	30
38	16	1	8	0	1	33
39	16	2	8	0	1	33
40	17	1	8	1	0	32
41	17	2	8	0	1	30
42	17	3	8	1	0	32
43	18	1	8	1	0	28
44	18	2	8	1	0	28
45	19	1	8	0	1	28
46	19	2	8	0	1	28
47	20	1	8	1	0	26
48	20	2	8	0	1	27
49	20	3	8	0	1	27
50	21	1	8	1	0	26
51	21	2	8	0	1	28
52	21	3	8	0	1	28
53	22	1	8	1	0	27
54	22	2	8	0	1	28
55	22	3	8	1	0	27
56	22	4	8	0	1	28
57	22	5	8	1	0	27
58	23	1	2	13	7	9
59	23	2	3	13	9	9
60	24	1	5	13	11	9
61	24	2	4	10	13	22
62	24	3	1	13	8	9
63	25	1	7	13	5	9
64	25	2	6	13	10	9
65	26	1	3	13	9	10
66	26	2	2	11	13	5
67	26	3	5	16	14	10
68	27	1	4	13	7	10
69	27	2	1	9	13	11
70	27	3	7	13	11	10
71	28	1	6	13	10	10
72	28	2	3	8	13	12
73	28	3	2	13	9	10
74	29	1	5	13	4	5
75	29	2	4	13	6	5
76	30	1	3	13	8	5
77	30	2	1	13	11	5
78	31	1	2	13	10	5
79	31	2	7	11	13	23
80	31	3	6	13	9	5
81	32	1	4	13	5	11
82	32	2	5	13	7	11
83	33	1	3	13	9	11
84	33	2	1	13	8	11
85	34	1	2	13	6	11
86	34	2	6	13	10	11
87	35	1	7	13	11	12
88	35	2	4	10	13	24
89	35	3	5	13	9	12
90	36	1	3	13	8	12
91	36	2	1	9	13	21
92	36	3	2	16	13	12
93	37	1	6	13	5	12
94	37	2	4	13	7	12
95	38	1	5	13	10	13
96	38	2	7	11	13	14
97	38	3	3	13	9	13
98	39	1	2	11	13	23
99	39	2	1	13	9	13
100	39	3	6	14	16	23
101	40	1	4	13	8	13
102	40	2	5	10	13	24
103	40	3	7	13	11	13
104	41	1	3	13	9	13
105	41	2	2	11	13	18
106	41	3	1	13	7	13
107	42	1	6	13	4	7
108	42	2	4	13	8	7
109	43	1	5	13	6	7
110	43	2	7	13	9	7
111	44	1	3	13	7	7
112	44	2	2	13	5	7
113	45	1	1	13	10	7
114	45	2	6	11	13	22
115	45	3	4	13	9	7
116	46	1	5	13	3	21
117	46	2	7	13	6	21
118	47	1	3	11	13	22
119	47	2	2	13	10	21
120	47	3	1	14	16	22
121	48	1	6	13	9	21
122	48	2	4	11	13	14
123	48	3	5	13	8	21
124	49	1	7	13	7	21
125	49	2	3	13	10	21
126	50	1	2	13	11	22
127	50	2	1	9	13	18
128	50	3	6	13	10	22
129	51	1	4	13	9	23
130	51	2	5	10	13	15
131	51	3	7	16	13	23
132	52	1	3	13	10	18
133	52	2	2	11	13	17
134	52	3	1	13	8	18
135	53	1	6	13	5	14
136	53	2	4	13	8	14
137	54	1	5	13	6	24
138	54	2	7	13	9	24
139	55	1	3	13	4	15
140	55	2	2	13	7	15
\.


--
-- Data for Name: heroes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.heroes (id, name, game_id) FROM stdin;
1	Abaddon	2
2	Alchemist	2
3	Ancient Apparition	2
4	Anti-Mage	2
5	Arc Warden	2
6	Axe	2
7	Bane	2
8	Batrider	2
9	Beastmaster	2
10	Bloodseeker	2
11	Bounty Hunter	2
12	Brewmaster	2
13	Bristleback	2
14	Broodmother	2
15	Centaur Warrunner	2
16	Chaos Knight	2
17	Chen	2
18	Clinkz	2
19	Clockwerk	2
20	Crystal Maiden	2
21	Dark Seer	2
22	Dark Willow	2
23	Dawnbreaker	2
24	Dazzle	2
25	Death Prophet	2
26	Disruptor	2
27	Doom	2
28	Dragon Knight	2
29	Drow Ranger	2
30	Earth Spirit	2
31	Earthshaker	2
32	Elder Titan	2
33	Ember Spirit	2
34	Enchantress	2
35	Enigma	2
36	Faceless Void	2
37	Grimstroke	2
38	Gyrocopter	2
39	Hoodwink	2
40	Huskar	2
41	Invoker	2
42	Io	2
43	Jakiro	2
44	Juggernaut	2
45	Keeper of the Light	2
46	Kez	2
47	Kunkka	2
48	Legion Commander	2
49	Leshrac	2
50	Lich	2
51	Lifestealer	2
52	Lina	2
53	Lion	2
54	Lone Druid	2
55	Luna	2
56	Lycan	2
57	Magnus	2
58	Marci	2
59	Mars	2
60	Medusa	2
61	Meepo	2
62	Mirana	2
63	Monkey King	2
64	Morphling	2
65	Muerta	2
66	Naga Siren	2
67	Nature's Prophet	2
68	Necrophos	2
69	Night Stalker	2
70	Nyx Assassin	2
71	Ogre Magi	2
72	Omniknight	2
73	Oracle	2
74	Outworld Destroyer	2
75	Pangolier	2
76	Phantom Assassin	2
77	Phantom Lancer	2
78	Phoenix	2
79	Primal Beast	2
80	Puck	2
81	Pudge	2
82	Pugna	2
83	Queen of Pain	2
84	Razor	2
85	Riki	2
86	Ringmaster	2
87	Rubick	2
88	Sand King	2
89	Shadow Demon	2
90	Shadow Fiend	2
91	Shadow Shaman	2
92	Silencer	2
93	Skywrath Mage	2
94	Slardar	2
95	Slark	2
96	Snapfire	2
97	Sniper	2
98	Spectre	2
99	Spirit Breaker	2
100	Storm Spirit	2
101	Sven	2
102	Techies	2
103	Templar Assassin	2
104	Terrorblade	2
105	Tidehunter	2
106	Timbersaw	2
107	Tinker	2
108	Tiny	2
109	Treant Protector	2
110	Troll Warlord	2
111	Tusk	2
112	Underlord	2
113	Undying	2
114	Ursa	2
115	Vengeful Spirit	2
116	Venomancer	2
117	Viper	2
118	Visage	2
119	Void Spirit	2
120	Warlock	2
121	Weaver	2
122	Windranger	2
123	Winter Wywern	2
124	Witch Doctor	2
125	Wraith King	2
126	Zeus	2
\.


--
-- Data for Name: matches_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.matches_history (history_id, operation_type, operation_timestamp, operation_user, old_id, old_stage_id, old_team1_id, old_team2_id, old_winner_team_id, old_match_date, new_id, new_stage_id, new_team1_id, new_team2_id, new_winner_team_id, new_match_date) FROM stdin;
\.


--
-- Data for Name: player_game_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_game_stats (id, game_id, player_id, hero_id, kills, deaths, assists) FROM stdin;
1	1	36	\N	16	18	4
2	1	37	\N	14	17	5
3	1	38	\N	19	16	3
4	1	39	\N	17	19	6
5	1	40	\N	15	20	7
6	1	26	\N	24	15	6
7	1	27	\N	21	16	8
8	1	28	\N	19	17	7
9	1	29	\N	17	18	9
10	1	30	\N	15	19	10
11	2	36	\N	9	17	2
12	2	37	\N	8	16	3
13	2	38	\N	11	15	1
14	2	39	\N	10	18	4
15	2	40	\N	7	19	5
16	2	26	\N	28	9	5
17	2	27	\N	25	10	7
18	2	28	\N	22	11	6
19	2	29	\N	19	8	8
20	2	30	\N	16	7	9
21	3	31	\N	26	14	7
22	3	32	\N	23	15	9
23	3	33	\N	20	16	8
24	3	34	\N	18	17	10
25	3	35	\N	15	18	11
26	3	11	\N	17	19	5
27	3	12	\N	19	17	4
28	3	13	\N	16	20	6
29	3	15	\N	14	21	7
30	3	14	\N	15	19	8
31	4	31	\N	12	18	3
32	4	32	\N	10	17	4
33	4	33	\N	14	16	2
34	4	34	\N	13	19	5
35	4	35	\N	9	20	6
36	4	11	\N	23	11	7
37	4	12	\N	27	9	6
38	4	13	\N	21	12	8
39	4	15	\N	19	13	9
40	4	14	\N	20	12	9
41	5	31	\N	11	19	2
42	5	32	\N	9	18	3
43	5	33	\N	13	17	1
44	5	34	\N	12	20	4
45	5	35	\N	8	21	5
46	5	11	\N	25	10	8
47	5	12	\N	29	8	7
48	5	13	\N	22	11	9
49	5	15	\N	20	12	10
50	5	14	\N	21	11	10
51	6	16	\N	20	21	6
52	6	17	\N	18	20	7
53	6	18	\N	22	19	5
54	6	19	\N	19	22	8
55	6	20	\N	16	23	9
56	6	6	\N	26	17	7
57	6	7	\N	23	18	9
58	6	8	\N	21	19	8
59	6	9	\N	25	16	6
60	6	10	\N	19	20	10
61	7	16	\N	24	12	7
62	7	17	\N	21	13	9
63	7	18	\N	19	14	8
64	7	19	\N	17	15	10
65	7	20	\N	15	16	11
66	7	6	\N	14	18	3
67	7	7	\N	11	17	5
68	7	8	\N	13	16	4
69	7	9	\N	10	19	6
70	7	10	\N	12	15	7
71	8	16	\N	27	7	8
72	8	17	\N	25	8	10
73	8	18	\N	23	9	9
74	8	19	\N	21	10	11
75	8	20	\N	19	11	12
76	8	6	\N	8	16	2
77	8	7	\N	6	15	3
78	8	8	\N	7	14	4
79	8	9	\N	5	17	2
80	8	10	\N	9	13	5
81	9	21	\N	25	15	8
82	9	22	\N	22	16	10
83	9	23	\N	20	17	9
84	9	24	\N	18	18	11
85	9	25	\N	16	19	12
86	9	1	\N	16	18	5
87	9	2	\N	14	17	6
88	9	3	\N	13	16	7
89	9	4	\N	19	15	4
90	9	5	\N	12	19	8
91	10	21	\N	17	20	5
92	10	22	\N	15	19	6
93	10	23	\N	18	18	4
94	10	24	\N	16	21	7
95	10	25	\N	14	22	8
96	10	1	\N	24	14	7
97	10	2	\N	18	16	9
98	10	3	\N	16	15	11
99	10	4	\N	27	12	6
100	10	5	\N	15	17	10
101	11	21	\N	19	22	6
102	11	22	\N	17	21	7
103	11	23	\N	21	20	5
104	11	24	\N	18	23	8
105	11	25	\N	16	24	9
106	11	1	\N	28	16	8
107	11	2	\N	21	18	10
108	11	3	\N	19	17	12
109	11	4	\N	31	14	7
110	11	5	\N	17	19	11
111	12	26	\N	29	24	9
112	12	27	\N	27	23	11
113	12	28	\N	25	22	10
114	12	29	\N	23	25	12
115	12	30	\N	21	26	13
116	12	11	\N	26	23	10
117	12	12	\N	28	21	9
118	12	13	\N	24	24	11
119	12	15	\N	22	25	12
120	12	14	\N	23	22	13
121	13	26	\N	15	19	4
122	13	27	\N	13	18	5
123	13	28	\N	17	17	3
124	13	29	\N	14	20	6
125	13	30	\N	12	21	7
126	13	11	\N	24	13	8
127	13	12	\N	26	11	7
128	13	13	\N	22	14	9
129	13	15	\N	20	15	10
130	13	14	\N	21	14	10
131	14	26	\N	13	18	3
132	14	27	\N	11	17	4
133	14	28	\N	15	16	2
134	14	29	\N	12	19	5
135	14	30	\N	10	20	6
136	14	11	\N	23	12	9
137	14	12	\N	25	10	8
138	14	13	\N	21	13	10
139	14	15	\N	19	14	11
140	14	14	\N	20	13	11
141	15	16	\N	18	22	5
142	15	17	\N	16	21	6
143	15	18	\N	20	20	4
144	15	19	\N	17	23	7
145	15	20	\N	15	24	8
146	15	1	\N	26	17	9
147	15	2	\N	22	19	11
148	15	3	\N	20	18	13
149	15	4	\N	29	15	8
150	15	5	\N	18	20	12
151	16	16	\N	11	18	2
152	16	17	\N	9	17	3
153	16	18	\N	13	16	1
154	16	19	\N	10	19	4
155	16	20	\N	8	20	5
156	16	1	\N	22	12	7
157	16	2	\N	18	14	9
158	16	3	\N	16	13	11
159	16	4	\N	25	10	6
160	16	5	\N	14	16	10
161	17	11	\N	25	16	9
162	17	12	\N	27	14	8
163	17	13	\N	23	17	10
164	17	15	\N	21	18	11
165	17	14	\N	22	17	12
166	17	1	\N	18	19	6
167	17	2	\N	16	18	8
168	17	3	\N	14	17	9
169	17	4	\N	21	16	5
170	17	5	\N	13	20	10
171	18	11	\N	24	14	8
172	18	12	\N	26	12	7
173	18	13	\N	22	15	9
174	18	15	\N	20	16	10
175	18	14	\N	21	15	11
176	18	1	\N	15	17	5
177	18	2	\N	13	16	7
178	18	3	\N	11	15	8
179	18	4	\N	18	14	4
180	18	5	\N	10	18	9
181	19	11	\N	28	9	10
182	19	12	\N	30	7	9
183	19	13	\N	26	10	11
184	19	15	\N	24	11	12
185	19	14	\N	25	10	13
186	19	1	\N	9	16	3
187	19	2	\N	7	15	5
188	19	3	\N	6	14	6
189	19	4	\N	12	13	2
190	19	5	\N	5	17	7
191	20	16	\N	26	11	9
192	20	17	\N	24	12	11
193	20	18	\N	22	13	10
194	20	19	\N	20	14	12
195	20	20	\N	18	15	13
196	20	26	\N	12	19	3
197	20	27	\N	10	18	4
198	20	28	\N	14	17	2
199	20	29	\N	11	20	5
200	20	30	\N	9	21	6
201	21	16	\N	25	15	8
202	21	17	\N	23	16	10
203	21	18	\N	21	17	9
204	21	19	\N	19	18	11
205	21	20	\N	17	19	12
206	21	26	\N	16	20	4
207	21	27	\N	14	19	5
208	21	28	\N	18	18	3
209	21	29	\N	15	21	6
210	21	30	\N	13	22	7
211	22	131	64	14	2	9
212	22	132	80	10	3	15
213	22	133	59	5	4	18
214	22	134	20	3	5	22
215	22	135	53	2	4	24
216	22	136	77	7	8	6
217	22	137	90	5	9	8
218	22	138	15	3	10	12
219	22	139	7	2	11	10
220	22	140	37	1	10	14
221	23	131	104	16	1	11
222	23	132	100	12	2	17
223	23	133	6	6	3	20
224	23	134	87	4	4	25
225	23	135	124	3	3	27
226	23	136	44	6	9	5
227	23	137	41	4	10	7
228	23	138	27	2	11	9
229	23	139	91	1	12	8
230	23	140	31	2	11	11
231	24	121	36	13	2	10
232	24	122	83	9	3	16
233	24	123	105	5	4	19
234	24	124	53	3	5	23
235	24	125	20	2	4	25
236	24	141	4	6	7	5
237	24	142	52	4	8	7
238	24	143	59	2	9	9
239	24	144	7	1	10	8
240	24	145	37	2	9	11
241	25	121	76	15	1	12
242	25	122	80	11	2	18
243	25	123	94	6	3	21
244	25	124	87	4	4	26
245	25	125	124	3	3	28
246	25	141	98	5	8	4
247	25	142	90	3	9	6
248	25	143	15	1	10	8
249	25	144	91	2	11	7
250	25	145	31	1	10	9
251	26	146	55	6	8	5
252	26	147	100	4	9	7
253	26	148	6	2	10	9
254	26	149	7	1	11	8
255	26	150	53	2	10	10
256	26	126	64	14	2	10
257	26	127	41	11	3	13
258	26	128	87	4	4	21
259	26	129	20	3	5	19
260	26	130	59	7	3	17
261	27	146	77	5	9	4
262	27	147	80	3	10	6
263	27	148	27	1	11	8
264	27	149	37	2	12	7
265	27	150	124	1	11	9
266	27	126	104	16	1	12
267	27	127	90	13	2	15
268	27	128	31	5	3	23
269	27	129	53	4	4	20
270	27	130	15	8	2	18
271	28	151	36	15	3	11
272	28	152	83	12	4	14
273	28	153	59	6	5	19
274	28	154	20	4	6	22
275	28	155	87	3	5	24
276	28	156	4	7	9	6
277	28	157	52	5	10	8
278	28	158	6	3	11	10
279	28	159	7	2	12	9
280	28	160	53	3	11	11
281	29	151	76	8	7	7
282	29	152	100	6	8	9
283	29	153	15	4	9	11
284	29	154	91	3	10	10
285	29	155	37	2	9	12
286	29	156	64	14	4	10
287	29	157	41	11	5	13
288	29	158	105	5	6	18
289	29	159	20	4	7	20
290	29	160	31	3	6	22
291	30	151	104	17	2	13
292	30	152	80	13	3	16
293	30	153	27	7	4	20
294	30	154	53	5	5	24
295	30	155	124	4	4	26
296	30	156	44	6	10	5
297	30	157	90	4	11	7
298	30	158	59	2	12	9
299	30	159	7	1	13	8
300	30	160	87	3	12	10
301	31	131	55	7	8	6
302	31	132	100	5	9	8
303	31	133	15	3	10	10
304	31	134	7	2	11	9
305	31	135	37	1	10	11
306	31	121	64	14	3	11
307	31	122	41	11	4	15
308	31	123	59	6	5	20
309	31	124	20	4	6	24
310	31	125	87	3	5	26
311	32	131	77	6	9	5
312	32	132	80	4	10	7
313	32	133	6	2	11	9
314	32	134	53	1	12	8
315	32	135	124	2	11	10
316	32	121	104	16	2	13
317	32	122	83	13	3	17
318	32	123	105	7	4	22
319	32	124	53	5	5	25
320	32	125	31	4	4	28
321	33	126	36	15	3	12
322	33	127	80	12	4	15
323	33	128	57	6	5	22
324	33	129	20	4	6	20
325	33	130	6	8	4	18
326	33	151	4	7	10	6
327	33	152	90	5	11	8
328	33	153	59	3	12	10
329	33	154	7	2	13	9
330	33	155	53	3	12	11
331	34	126	76	9	7	8
332	34	127	100	7	8	10
333	34	128	87	4	9	14
334	34	129	37	3	10	13
335	34	130	15	5	8	11
336	34	151	64	14	5	11
337	34	152	41	11	6	14
338	34	153	105	6	7	19
339	34	154	20	4	8	21
340	34	155	31	3	7	23
341	35	126	104	18	2	14
342	35	127	33	14	3	17
343	35	128	31	7	4	24
344	35	129	53	5	5	22
345	35	130	27	10	3	20
346	35	151	44	6	11	5
347	35	152	80	4	12	7
348	35	153	59	2	13	9
349	35	154	7	1	14	8
350	35	155	124	3	13	10
351	36	136	55	6	8	5
352	36	137	83	4	9	7
353	36	138	59	2	10	9
354	36	139	20	1	11	8
355	36	140	53	2	10	10
356	36	141	64	13	3	10
357	36	142	41	10	4	13
358	36	143	6	5	5	18
359	36	144	87	4	6	20
360	36	145	31	3	5	22
361	37	136	77	5	9	4
362	37	137	80	3	10	6
363	37	138	15	1	11	8
364	37	139	7	2	12	7
365	37	140	37	1	11	9
366	37	141	104	15	2	11
367	37	142	100	12	3	14
368	37	143	105	6	4	19
369	37	144	20	4	5	21
370	37	145	53	3	4	23
371	38	146	4	6	8	5
372	38	147	90	4	9	7
373	38	148	59	2	10	9
374	38	149	7	1	11	8
375	38	150	87	2	10	10
376	38	156	36	14	3	11
377	38	157	80	11	4	14
378	38	158	6	6	5	19
379	38	159	20	4	6	21
380	38	160	53	3	5	23
381	39	146	44	5	9	4
382	39	147	41	3	10	6
383	39	148	27	1	11	8
384	39	149	37	2	12	7
385	39	150	31	1	11	9
386	39	156	64	16	2	12
387	39	157	83	13	3	15
388	39	158	105	7	4	20
389	39	159	124	5	5	22
390	39	160	87	4	4	24
391	40	151	76	14	3	11
392	40	152	100	11	4	14
393	40	153	15	6	5	19
394	40	154	20	4	6	21
395	40	155	53	3	5	23
396	40	141	55	6	8	5
397	40	142	90	4	9	7
398	40	143	59	2	10	9
399	40	144	7	1	11	8
400	40	145	37	2	10	10
401	41	151	44	8	7	7
402	41	152	80	6	8	9
403	41	153	6	4	9	11
404	41	154	87	3	10	10
405	41	155	31	2	9	12
406	41	141	64	13	4	10
407	41	142	41	10	5	13
408	41	143	105	5	6	18
409	41	144	20	4	7	20
410	41	145	53	3	6	22
411	42	151	104	16	2	13
412	42	152	33	13	3	16
413	42	153	27	7	4	21
414	42	154	124	5	5	23
415	42	155	37	4	4	25
416	42	141	77	5	10	4
417	42	142	83	3	11	6
418	42	143	59	1	12	8
419	42	144	7	2	13	7
420	42	145	87	1	12	9
421	43	131	36	15	3	12
422	43	132	100	12	4	15
423	43	133	59	6	5	20
424	43	134	20	4	6	22
425	43	135	87	3	5	24
426	43	156	4	7	9	6
427	43	157	80	5	10	8
428	43	158	15	3	11	10
429	43	159	7	2	12	9
430	43	160	53	3	11	11
431	44	131	104	17	2	14
432	44	132	41	14	3	17
433	44	133	105	7	4	22
434	44	134	53	5	5	24
435	44	135	31	4	4	26
436	44	156	44	6	10	5
437	44	157	90	4	11	7
438	44	158	6	2	12	9
439	44	159	37	1	13	8
440	44	160	124	3	12	10
441	45	121	76	14	4	11
442	45	122	80	11	5	14
443	45	123	59	6	6	19
444	45	124	20	4	7	21
445	45	125	87	3	6	23
446	45	126	55	8	8	7
447	45	127	100	6	9	9
448	45	128	31	4	10	13
449	45	129	7	3	11	12
450	45	130	15	5	9	11
451	46	121	44	8	7	8
452	46	122	41	6	8	10
453	46	123	6	4	9	12
454	46	124	53	3	10	11
455	46	125	37	2	9	13
456	46	126	64	14	4	11
457	46	127	83	11	5	14
458	46	128	57	6	6	20
459	46	129	20	4	7	18
460	46	130	59	7	5	16
461	47	121	77	7	8	6
462	47	122	90	5	9	8
463	47	123	27	3	10	10
464	47	124	124	2	11	9
465	47	125	31	1	10	11
466	47	126	104	15	3	13
467	47	127	33	12	4	16
468	47	128	105	6	5	21
469	47	129	53	5	6	19
470	47	130	15	8	4	17
471	48	121	36	13	4	10
472	48	122	80	10	5	13
473	48	123	59	5	6	18
474	48	124	20	4	7	20
475	48	125	87	3	6	22
476	48	131	4	7	8	6
477	48	132	100	5	9	8
478	48	133	15	3	10	10
479	48	134	7	2	11	9
480	48	135	53	3	11	11
481	49	121	44	8	7	7
482	49	122	41	6	8	9
483	49	123	6	4	9	11
484	49	124	37	3	10	10
485	49	125	31	2	9	12
486	49	131	64	14	4	11
487	49	132	83	11	5	14
488	49	133	105	6	6	19
489	49	134	20	4	7	21
490	49	135	124	3	6	23
491	50	121	76	7	8	6
492	50	122	90	5	9	8
493	50	123	27	3	10	10
494	50	124	53	2	11	9
495	50	125	87	1	10	11
496	50	131	104	16	3	13
497	50	132	33	13	4	16
498	50	133	59	7	5	21
499	50	134	7	5	6	19
500	50	135	37	4	5	22
501	51	126	36	16	3	13
502	51	127	80	13	4	16
503	51	128	57	7	5	23
504	51	129	20	5	6	21
505	51	130	59	9	4	19
506	51	131	77	7	9	6
507	51	132	41	5	10	8
508	51	133	15	3	11	10
509	51	134	7	2	12	9
510	51	135	53	3	11	11
511	52	126	76	9	7	8
512	52	127	100	7	8	10
513	52	128	87	4	9	14
514	52	129	37	3	10	13
515	52	130	6	5	8	11
516	52	131	64	14	5	11
517	52	132	83	11	6	14
518	52	133	105	6	7	19
519	52	134	20	4	8	21
520	52	135	31	3	7	23
521	53	126	104	18	2	15
522	53	127	33	15	3	18
523	53	128	31	8	4	25
524	53	129	53	6	5	23
525	53	130	27	11	3	21
526	53	131	44	6	11	5
527	53	132	90	4	12	7
528	53	133	59	2	13	9
529	53	134	7	1	14	8
530	53	135	124	3	13	10
531	54	126	55	8	8	7
532	54	127	41	6	9	9
533	54	128	57	4	10	13
534	54	129	20	3	11	12
535	54	130	15	5	9	11
536	54	131	36	15	5	12
537	54	132	80	12	6	15
538	54	133	6	7	7	20
539	54	134	87	5	8	22
540	54	135	37	4	7	24
541	55	126	64	20	2	16
542	55	127	83	17	3	19
543	55	128	31	9	4	27
544	55	129	53	7	5	25
545	55	130	79	13	3	23
546	55	131	76	7	12	6
547	55	132	100	5	13	8
548	55	133	105	3	14	10
549	55	134	7	2	15	9
550	55	135	124	3	14	11
\.


--
-- Data for Name: player_teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.player_teams (player_id, team_id, role) FROM stdin;
1	1	\N
2	1	\N
3	1	\N
4	1	\N
5	1	\N
6	2	\N
7	2	\N
8	2	\N
9	2	\N
10	2	\N
11	3	\N
12	3	\N
13	3	\N
14	3	\N
15	3	\N
16	4	\N
17	4	\N
18	4	\N
19	4	\N
20	4	\N
21	5	\N
22	5	\N
23	5	\N
24	5	\N
25	5	\N
26	6	\N
27	6	\N
28	6	\N
29	6	\N
30	6	\N
31	7	\N
32	7	\N
33	7	\N
34	7	\N
35	7	\N
36	8	\N
37	8	\N
38	8	\N
39	8	\N
40	8	\N
41	9	\N
42	9	\N
43	9	\N
44	9	\N
45	9	\N
46	10	\N
47	10	\N
48	10	\N
49	10	\N
50	10	\N
51	11	\N
52	11	\N
53	11	\N
54	11	\N
55	11	\N
56	12	\N
57	12	\N
58	12	\N
59	12	\N
60	12	\N
61	13	\N
62	13	\N
63	13	\N
64	13	\N
65	13	\N
66	14	\N
67	14	\N
68	14	\N
69	14	\N
70	14	\N
71	15	\N
72	15	\N
73	15	\N
74	15	\N
75	15	\N
76	16	\N
77	16	\N
78	16	\N
79	16	\N
80	16	\N
81	17	\N
82	17	\N
83	17	\N
84	17	\N
85	17	\N
86	18	\N
87	18	\N
88	18	\N
89	18	\N
90	18	\N
91	19	\N
92	19	\N
93	19	\N
94	19	\N
95	19	\N
96	20	\N
97	20	\N
98	20	\N
99	20	\N
100	20	\N
101	21	\N
102	21	\N
103	21	\N
104	21	\N
105	21	\N
106	22	\N
107	22	\N
108	22	\N
109	22	\N
110	22	\N
111	23	\N
112	23	\N
113	23	\N
114	23	\N
115	23	\N
116	25	\N
117	25	\N
118	25	\N
119	25	\N
120	25	\N
121	26	\N
122	26	\N
123	26	\N
124	26	\N
125	26	\N
126	27	\N
127	27	\N
128	27	\N
129	27	\N
130	27	\N
131	28	\N
132	28	\N
133	28	\N
134	28	\N
135	28	\N
136	29	\N
137	29	\N
138	29	\N
139	29	\N
140	29	\N
141	30	\N
142	30	\N
143	30	\N
144	30	\N
145	30	\N
146	31	\N
147	31	\N
148	31	\N
149	31	\N
150	31	\N
151	32	\N
152	32	\N
153	32	\N
154	32	\N
155	32	\N
156	33	\N
157	33	\N
158	33	\N
159	33	\N
160	33	\N
161	34	\N
162	34	\N
163	34	\N
164	34	\N
165	34	\N
166	35	\N
167	35	\N
168	35	\N
169	35	\N
170	35	\N
171	36	\N
172	36	\N
173	36	\N
174	36	\N
175	36	\N
176	37	\N
177	37	\N
178	37	\N
179	37	\N
180	37	\N
181	38	\N
182	38	\N
183	38	\N
184	38	\N
185	38	\N
186	39	\N
187	39	\N
188	39	\N
189	39	\N
190	39	\N
191	40	\N
192	40	\N
193	40	\N
194	40	\N
195	40	\N
\.


--
-- Data for Name: players_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players_history (history_id, operation_type, operation_timestamp, operation_user, old_id, old_nickname, old_full_name, old_birthdate, old_country_id, old_role, old_total_winnings, old_status, new_id, new_nickname, new_full_name, new_birthdate, new_country_id, new_role, new_total_winnings, new_status) FROM stdin;
1	INSERT	2025-12-09 00:08:30.77702	esports_operator	\N	\N	\N	\N	\N	\N	\N	\N	196	test	test	1111-10-10	17	test	100	active
2	INSERT	2025-12-09 00:10:35.63255	esports_admin	\N	\N	\N	\N	\N	\N	\N	\N	197	test_admin	test_admin	1111-10-10	20	test_admin	100	active
3	DELETE	2025-12-09 00:19:52.432554	esports_admin	196	test	test	1111-10-10	17	test	100	active	\N	\N	\N	\N	\N	\N	\N	\N
36	INSERT	2025-12-09 07:54:07.544585	esports_operator	\N	\N	\N	\N	\N	\N	\N	\N	198	TEST_OPERATOR	TEST_OPERATOR	1111-10-10	9	TEST_OPERATOR	1	active
\.


--
-- Data for Name: team_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_locations (team_id, country_id) FROM stdin;
1	6
1	2
2	7
2	2
3	10
4	11
5	10
6	2
7	12
8	8
8	9
21	2
22	7
23	15
20	16
9	30
10	30
11	30
12	30
13	30
14	30
15	30
16	30
17	30
18	30
19	30
27	6
27	9
25	8
25	9
26	8
26	9
28	13
29	2
30	30
31	30
32	14
33	2
34	19
34	2
35	19
36	13
36	3
37	28
37	3
38	7
38	1
39	30
39	2
40	8
40	14
\.


--
-- Data for Name: teams_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams_history (history_id, operation_type, operation_timestamp, operation_user, old_id, old_name, old_created_at, old_disbanded_at, old_coach, old_manager, old_total_earnings, old_game_id, old_captain_id, new_id, new_name, new_created_at, new_disbanded_at, new_coach, new_manager, new_total_earnings, new_game_id, new_captain_id) FROM stdin;
1	INSERT	2025-12-09 00:09:21.816375	esports_operator	\N	\N	\N	\N	\N	\N	\N	\N	\N	41	test	1111-10-10	\N	test	test	10	1	44
2	INSERT	2025-12-09 00:10:51.330022	esports_admin	\N	\N	\N	\N	\N	\N	\N	\N	\N	42	test_admin	1111-10-10	\N	test_admin	test_admin	100	2	10
3	DELETE	2025-12-09 00:19:40.622594	esports_admin	42	test_admin	1111-10-10	\N	test_admin	test_admin	100	2	10	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: tournament_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tournament_participants (id, tournament_id, team_id, place, earnings) FROM stdin;
1	1	26	1	1224732
2	1	24	13	51817
3	1	25	3	259319
4	1	27	2	374676
5	1	31	4	172918
6	1	29	5	144079
7	1	32	6	144079
8	1	28	7	115240
9	1	30	8	115240
10	2	1	2	50000
11	2	2	7	18000
12	2	3	1	100000
13	2	4	3	28000
14	2	6	4	22000
15	2	8	5	18000
16	2	7	6	18000
17	2	5	8	18000
\.


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: esports_admin
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: esports_admin
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: esports_admin
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 96, true);


--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: esports_admin
--

SELECT pg_catalog.setval('public.auth_user_groups_id_seq', 1, false);


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: esports_admin
--

SELECT pg_catalog.setval('public.auth_user_id_seq', 1, true);


--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: esports_admin
--

SELECT pg_catalog.setval('public.auth_user_user_permissions_id_seq', 1, false);


--
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.countries_id_seq', 30, true);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: esports_admin
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: esports_admin
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 24, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: esports_admin
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 19, true);


--
-- Name: game_genres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.game_genres_id_seq', 5, true);


--
-- Name: games_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.games_id_seq', 140, true);


--
-- Name: games_list_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.games_list_id_seq', 2, true);


--
-- Name: heroes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.heroes_id_seq', 126, true);


--
-- Name: maps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.maps_id_seq', 8, true);


--
-- Name: matches_history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.matches_history_history_id_seq', 1, false);


--
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.matches_id_seq', 128, true);


--
-- Name: player_game_stats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.player_game_stats_id_seq', 550, true);


--
-- Name: players_history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.players_history_history_id_seq', 36, true);


--
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.players_id_seq', 198, true);


--
-- Name: teams_history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teams_history_history_id_seq', 36, true);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teams_id_seq', 43, true);


--
-- Name: tournament_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournament_participants_id_seq', 17, true);


--
-- Name: tournament_stages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournament_stages_id_seq', 15, true);


--
-- Name: tournaments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tournaments_id_seq', 5, true);


--
-- PostgreSQL database dump complete
--

\unrestrict e7z4XC8xUNaaCt0BgtvKs1MqPxxh01AalAuRLXuJhCAP9UA6pr6LhDHJpX19jrE

