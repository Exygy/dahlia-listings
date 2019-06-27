PGDMP     
                    w           dahlia_staging    11.1    11.2 A    F           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            G           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            H           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            I           1262    16582    dahlia_staging    DATABASE     �   CREATE DATABASE dahlia_staging WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';
    DROP DATABASE dahlia_staging;
             regional_dahlia_staging_admin    false            �            1259    16957 
   ami_charts    TABLE       CREATE TABLE public.ami_charts (
    id bigint NOT NULL,
    ami_values_file character varying,
    chart_type character varying,
    year integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_id integer
);
    DROP TABLE public.ami_charts;
       public         regional_dahlia_staging_admin    false            �            1259    16955    ami_charts_id_seq    SEQUENCE     z   CREATE SEQUENCE public.ami_charts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.ami_charts_id_seq;
       public       regional_dahlia_staging_admin    false    207            J           0    0    ami_charts_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.ami_charts_id_seq OWNED BY public.ami_charts.id;
            public       regional_dahlia_staging_admin    false    206            �            1259    16669    ar_internal_metadata    TABLE     �   CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);
 (   DROP TABLE public.ar_internal_metadata;
       public         regional_dahlia_staging_admin    false            �            1259    16905    groups    TABLE     �  CREATE TABLE public.groups (
    id bigint NOT NULL,
    name character varying,
    slug character varying,
    domain character varying,
    group_type integer,
    parent_id integer,
    lft integer NOT NULL,
    rgt integer NOT NULL,
    depth integer DEFAULT 0 NOT NULL,
    children_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    gtm_key character varying
);
    DROP TABLE public.groups;
       public         regional_dahlia_staging_admin    false            �            1259    16903    groups_id_seq    SEQUENCE     v   CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.groups_id_seq;
       public       regional_dahlia_staging_admin    false    201            K           0    0    groups_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;
            public       regional_dahlia_staging_admin    false    200            �            1259    16927    listings    TABLE     T	  CREATE TABLE public.listings (
    id bigint NOT NULL,
    accepting_applications_at_leasing_agent boolean DEFAULT false NOT NULL,
    accepting_applications_by_po_box boolean DEFAULT false NOT NULL,
    accepting_online_applications boolean DEFAULT false NOT NULL,
    accessibility character varying,
    amenities character varying,
    application_due_date timestamp without time zone,
    application_organization character varying,
    application_city character varying,
    application_phone character varying,
    application_postal_code character varying,
    application_state character varying,
    application_street_address character varying,
    blank_paper_application_can_be_picked_up boolean DEFAULT false NOT NULL,
    building_city character varying,
    building_name character varying,
    building_selection_criteria text,
    building_state character varying,
    building_street_address character varying,
    building_zip_code character varying,
    costs_not_included text,
    credit_history text,
    deposit_max numeric(8,2),
    deposit_min numeric(8,2),
    developer character varying,
    image_url character varying,
    program_rules text,
    external_id character varying,
    waitlist_max_size integer,
    name character varying,
    neighborhood character varying,
    waitlist_current_size integer,
    pet_policy text,
    priorities_descriptor character varying,
    required_documents text,
    reserved_community_maximum_age integer,
    reserved_community_minimum_age integer,
    reserved_descriptor character varying,
    smoking_policy text,
    year_built integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    group_id integer,
    hide_unit_features boolean DEFAULT false NOT NULL,
    unit_amenities text,
    application_download_url character varying,
    application_fee numeric(5,2),
    criminal_background text,
    leasing_agent_city character varying,
    leasing_agent_email character varying,
    leasing_agent_name character varying,
    leasing_agent_office_hours character varying,
    leasing_agent_phone character varying,
    leasing_agent_state character varying,
    leasing_agent_street character varying,
    leasing_agent_title character varying,
    leasing_agent_zip character varying,
    rental_history text,
    building_total_units integer
);
    DROP TABLE public.listings;
       public         regional_dahlia_staging_admin    false            �            1259    16925    listings_id_seq    SEQUENCE     x   CREATE SEQUENCE public.listings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.listings_id_seq;
       public       regional_dahlia_staging_admin    false    203            L           0    0    listings_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.listings_id_seq OWNED BY public.listings.id;
            public       regional_dahlia_staging_admin    false    202            �            1259    16970    preferences    TABLE     �  CREATE TABLE public.preferences (
    id bigint NOT NULL,
    available_units_count integer,
    available_units_percent integer,
    description text,
    name character varying,
    "order" integer,
    pdf_url character varying,
    preference_proof_requirement_description text,
    read_more_url character varying,
    requires_proof boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    listing_id integer
);
    DROP TABLE public.preferences;
       public         regional_dahlia_staging_admin    false            �            1259    16968    preferences_id_seq    SEQUENCE     {   CREATE SEQUENCE public.preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.preferences_id_seq;
       public       regional_dahlia_staging_admin    false    209            M           0    0    preferences_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.preferences_id_seq OWNED BY public.preferences.id;
            public       regional_dahlia_staging_admin    false    208            �            1259    16715    schema_migrations    TABLE     R   CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);
 %   DROP TABLE public.schema_migrations;
       public         regional_dahlia_staging_admin    false            �            1259    16944    units    TABLE     �  CREATE TABLE public.units (
    id bigint NOT NULL,
    ami_percentage numeric(5,2),
    annual_income_min numeric(8,2),
    monthly_income_min numeric(8,2),
    floor integer,
    annual_income_max numeric(8,2),
    max_occupancy integer,
    min_occupancy integer,
    monthly_rent numeric(8,2),
    num_bathrooms integer,
    num_bedrooms integer,
    number character varying,
    priority_type integer,
    reserved_type integer,
    sq_ft integer,
    status integer,
    unit_type integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    listing_id integer,
    ami_chart_id integer,
    monthly_rent_as_percent_of_income integer
);
    DROP TABLE public.units;
       public         regional_dahlia_staging_admin    false            �            1259    16942    units_id_seq    SEQUENCE     u   CREATE SEQUENCE public.units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.units_id_seq;
       public       regional_dahlia_staging_admin    false    205            N           0    0    units_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.units_id_seq OWNED BY public.units.id;
            public       regional_dahlia_staging_admin    false    204            �            1259    16888    users    TABLE     z  CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    provider character varying,
    uid character varying,
    salesforce_user_id character varying,
    salesforce_account_id character varying,
    oauth_token character varying,
    admin boolean DEFAULT false,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    role integer,
    group_id bigint
);
    DROP TABLE public.users;
       public         regional_dahlia_staging_admin    false            �            1259    16886    users_id_seq    SEQUENCE     u   CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public       regional_dahlia_staging_admin    false    199            O           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
            public       regional_dahlia_staging_admin    false    198            �           2604    16960    ami_charts id    DEFAULT     n   ALTER TABLE ONLY public.ami_charts ALTER COLUMN id SET DEFAULT nextval('public.ami_charts_id_seq'::regclass);
 <   ALTER TABLE public.ami_charts ALTER COLUMN id DROP DEFAULT;
       public       regional_dahlia_staging_admin    false    207    206    207            �           2604    16908 	   groups id    DEFAULT     f   ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);
 8   ALTER TABLE public.groups ALTER COLUMN id DROP DEFAULT;
       public       regional_dahlia_staging_admin    false    201    200    201            �           2604    16930    listings id    DEFAULT     j   ALTER TABLE ONLY public.listings ALTER COLUMN id SET DEFAULT nextval('public.listings_id_seq'::regclass);
 :   ALTER TABLE public.listings ALTER COLUMN id DROP DEFAULT;
       public       regional_dahlia_staging_admin    false    203    202    203            �           2604    16973    preferences id    DEFAULT     p   ALTER TABLE ONLY public.preferences ALTER COLUMN id SET DEFAULT nextval('public.preferences_id_seq'::regclass);
 =   ALTER TABLE public.preferences ALTER COLUMN id DROP DEFAULT;
       public       regional_dahlia_staging_admin    false    209    208    209            �           2604    16947    units id    DEFAULT     d   ALTER TABLE ONLY public.units ALTER COLUMN id SET DEFAULT nextval('public.units_id_seq'::regclass);
 7   ALTER TABLE public.units ALTER COLUMN id DROP DEFAULT;
       public       regional_dahlia_staging_admin    false    205    204    205            �           2604    16891    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public       regional_dahlia_staging_admin    false    198    199    199            A          0    16957 
   ami_charts 
   TABLE DATA               m   COPY public.ami_charts (id, ami_values_file, chart_type, year, created_at, updated_at, group_id) FROM stdin;
    public       regional_dahlia_staging_admin    false    207   �a       6          0    16669    ar_internal_metadata 
   TABLE DATA               R   COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
    public       regional_dahlia_staging_admin    false    196   
b       ;          0    16905    groups 
   TABLE DATA               �   COPY public.groups (id, name, slug, domain, group_type, parent_id, lft, rgt, depth, children_count, created_at, updated_at, gtm_key) FROM stdin;
    public       regional_dahlia_staging_admin    false    201   Yb       =          0    16927    listings 
   TABLE DATA               �  COPY public.listings (id, accepting_applications_at_leasing_agent, accepting_applications_by_po_box, accepting_online_applications, accessibility, amenities, application_due_date, application_organization, application_city, application_phone, application_postal_code, application_state, application_street_address, blank_paper_application_can_be_picked_up, building_city, building_name, building_selection_criteria, building_state, building_street_address, building_zip_code, costs_not_included, credit_history, deposit_max, deposit_min, developer, image_url, program_rules, external_id, waitlist_max_size, name, neighborhood, waitlist_current_size, pet_policy, priorities_descriptor, required_documents, reserved_community_maximum_age, reserved_community_minimum_age, reserved_descriptor, smoking_policy, year_built, created_at, updated_at, group_id, hide_unit_features, unit_amenities, application_download_url, application_fee, criminal_background, leasing_agent_city, leasing_agent_email, leasing_agent_name, leasing_agent_office_hours, leasing_agent_phone, leasing_agent_state, leasing_agent_street, leasing_agent_title, leasing_agent_zip, rental_history, building_total_units) FROM stdin;
    public       regional_dahlia_staging_admin    false    203   c       C          0    16970    preferences 
   TABLE DATA               �   COPY public.preferences (id, available_units_count, available_units_percent, description, name, "order", pdf_url, preference_proof_requirement_description, read_more_url, requires_proof, created_at, updated_at, listing_id) FROM stdin;
    public       regional_dahlia_staging_admin    false    209   ay       7          0    16715    schema_migrations 
   TABLE DATA               4   COPY public.schema_migrations (version) FROM stdin;
    public       regional_dahlia_staging_admin    false    197   Zz       ?          0    16944    units 
   TABLE DATA               R  COPY public.units (id, ami_percentage, annual_income_min, monthly_income_min, floor, annual_income_max, max_occupancy, min_occupancy, monthly_rent, num_bathrooms, num_bedrooms, number, priority_type, reserved_type, sq_ft, status, unit_type, created_at, updated_at, listing_id, ami_chart_id, monthly_rent_as_percent_of_income) FROM stdin;
    public       regional_dahlia_staging_admin    false    205   �z       9          0    16888    users 
   TABLE DATA               ;  COPY public.users (id, email, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, created_at, updated_at, provider, uid, salesforce_user_id, salesforce_account_id, oauth_token, admin, encrypted_password, reset_password_token, reset_password_sent_at, role, group_id) FROM stdin;
    public       regional_dahlia_staging_admin    false    199   e{       P           0    0    ami_charts_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.ami_charts_id_seq', 1, false);
            public       regional_dahlia_staging_admin    false    206            Q           0    0    groups_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.groups_id_seq', 3, true);
            public       regional_dahlia_staging_admin    false    200            R           0    0    listings_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.listings_id_seq', 4, true);
            public       regional_dahlia_staging_admin    false    202            S           0    0    preferences_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.preferences_id_seq', 1, false);
            public       regional_dahlia_staging_admin    false    208            T           0    0    units_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.units_id_seq', 2, true);
            public       regional_dahlia_staging_admin    false    204            U           0    0    users_id_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.users_id_seq', 3, true);
            public       regional_dahlia_staging_admin    false    198            �           2606    16965    ami_charts ami_charts_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.ami_charts
    ADD CONSTRAINT ami_charts_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.ami_charts DROP CONSTRAINT ami_charts_pkey;
       public         regional_dahlia_staging_admin    false    207            �           2606    16676 .   ar_internal_metadata ar_internal_metadata_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);
 X   ALTER TABLE ONLY public.ar_internal_metadata DROP CONSTRAINT ar_internal_metadata_pkey;
       public         regional_dahlia_staging_admin    false    196            �           2606    16915    groups groups_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.groups DROP CONSTRAINT groups_pkey;
       public         regional_dahlia_staging_admin    false    201            �           2606    16940    listings listings_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.listings DROP CONSTRAINT listings_pkey;
       public         regional_dahlia_staging_admin    false    203            �           2606    16979    preferences preferences_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.preferences DROP CONSTRAINT preferences_pkey;
       public         regional_dahlia_staging_admin    false    209            �           2606    16722 (   schema_migrations schema_migrations_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);
 R   ALTER TABLE ONLY public.schema_migrations DROP CONSTRAINT schema_migrations_pkey;
       public         regional_dahlia_staging_admin    false    197            �           2606    16952    units units_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.units DROP CONSTRAINT units_pkey;
       public         regional_dahlia_staging_admin    false    205            �           2606    16898    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public         regional_dahlia_staging_admin    false    199            �           1259    16966 4   index_ami_charts_on_chart_type_and_year_and_group_id    INDEX     �   CREATE UNIQUE INDEX index_ami_charts_on_chart_type_and_year_and_group_id ON public.ami_charts USING btree (chart_type, year, group_id);
 H   DROP INDEX public.index_ami_charts_on_chart_type_and_year_and_group_id;
       public         regional_dahlia_staging_admin    false    207    207    207            �           1259    16967    index_ami_charts_on_group_id    INDEX     W   CREATE INDEX index_ami_charts_on_group_id ON public.ami_charts USING btree (group_id);
 0   DROP INDEX public.index_ami_charts_on_group_id;
       public         regional_dahlia_staging_admin    false    207            �           1259    16916    index_groups_on_lft    INDEX     E   CREATE INDEX index_groups_on_lft ON public.groups USING btree (lft);
 '   DROP INDEX public.index_groups_on_lft;
       public         regional_dahlia_staging_admin    false    201            �           1259    16917    index_groups_on_parent_id    INDEX     Q   CREATE INDEX index_groups_on_parent_id ON public.groups USING btree (parent_id);
 -   DROP INDEX public.index_groups_on_parent_id;
       public         regional_dahlia_staging_admin    false    201            �           1259    16918    index_groups_on_rgt    INDEX     E   CREATE INDEX index_groups_on_rgt ON public.groups USING btree (rgt);
 '   DROP INDEX public.index_groups_on_rgt;
       public         regional_dahlia_staging_admin    false    201            �           1259    16941    index_listings_on_group_id    INDEX     S   CREATE INDEX index_listings_on_group_id ON public.listings USING btree (group_id);
 .   DROP INDEX public.index_listings_on_group_id;
       public         regional_dahlia_staging_admin    false    203            �           1259    16980    index_preferences_on_listing_id    INDEX     ]   CREATE INDEX index_preferences_on_listing_id ON public.preferences USING btree (listing_id);
 3   DROP INDEX public.index_preferences_on_listing_id;
       public         regional_dahlia_staging_admin    false    209            �           1259    16953    index_units_on_ami_chart_id    INDEX     U   CREATE INDEX index_units_on_ami_chart_id ON public.units USING btree (ami_chart_id);
 /   DROP INDEX public.index_units_on_ami_chart_id;
       public         regional_dahlia_staging_admin    false    205            �           1259    16954    index_units_on_listing_id    INDEX     Q   CREATE INDEX index_units_on_listing_id ON public.units USING btree (listing_id);
 -   DROP INDEX public.index_units_on_listing_id;
       public         regional_dahlia_staging_admin    false    205            �           1259    16899    index_users_on_email    INDEX     N   CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);
 (   DROP INDEX public.index_users_on_email;
       public         regional_dahlia_staging_admin    false    199            �           1259    16919    index_users_on_group_id    INDEX     M   CREATE INDEX index_users_on_group_id ON public.users USING btree (group_id);
 +   DROP INDEX public.index_users_on_group_id;
       public         regional_dahlia_staging_admin    false    199            �           1259    16901    index_users_on_uid_and_provider    INDEX     a   CREATE UNIQUE INDEX index_users_on_uid_and_provider ON public.users USING btree (uid, provider);
 3   DROP INDEX public.index_users_on_uid_and_provider;
       public         regional_dahlia_staging_admin    false    199    199            �           2606    16920    users fk_rails_f40b3f4da6    FK CONSTRAINT     z   ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_f40b3f4da6 FOREIGN KEY (group_id) REFERENCES public.groups(id);
 C   ALTER TABLE ONLY public.users DROP CONSTRAINT fk_rails_f40b3f4da6;
       public       regional_dahlia_staging_admin    false    199    201    3754            A   l   x�3�LI,I�N��M,I��u120��K..��9A0�k`�kd�```edde`�]���4_W�q@�yf���桉q����\������0(� $��=... ��<d      6   ?   x�K�+�,���M�+�,(�O)M.����420��50�50V04�2"S=K3Csc<R\1z\\\ �\      ;   �   x�}Ͻ
�0���)���jc�ڡP�K;���-z%?�o�X�*���q��ȯ�-�w:�S���{��8k�$45(�$�T�L�LI�t��J�Q��^����K�Lq3��]���3�b��B��W%3����_�	B��[G�h�I�4�����\c��l�����}�N�      =      x��[��F��-?E!��tE�ҷ��iwێ�v�q��?�"Y��X�j�W�a-��Q�Q�$��Sŋ�'�NvӆmIT]N�:��;U
ɠ¿'����.E���2�dZ�f�R�y\nD��j(�^��R�U��H��PD�.��,���M�|�+�����wp"+��<��3��ڨ���?��d:������`2��x�=�X_�W��]�Q�UU���6�\��+]Is���$�T��� ���h���Y ��|*�?��G�j�O�ēK��R���p�r�W�܈ZYH3*SQU�QZm����s��_��R�HH'RC�k�uZ-��/J�@o2̔�U�MZ������G�/�L���!���%O �X�q��h�>�LU*�P�S����J�u�����u��]��>�{���L3���0؟c֕Ϋ�7xS��4�("*U��%�/+�6i̟�z%���Ny5O�0n*��X�%4�.Ou.bY9���)�F�L�]|�1B',�,�,�d�^+�q#�����o��.K�W4K���d�L3�>��*��$�>�D_�����g^/�hI���X�����#�����hZ�$�%��h�vU�`3!�@A!�X����Qg٬H]EJ�F�~�*Ls�H��K��a0�}߃��eVsKS�1-<�d�d"+�a�����2�(뢊6"M����K6H*��ѵ�i���V��V�g���a���*�`e�{����h-J˨^�J�2�������L��94=���^�@�z��f�^{
_,�sO��1���8V���8𘱩6�R�BU��j1.�+GM�������>���E��t9�#<3���	<pd�ԑ����n~��U�m�`�P���"F�1T���[V��zV�!�L����"��L�Ŋ��F��y�b����Z:Vn��J/y�)���'Mq�u!���p���d�Pգ/>�v�6Q���l5�t��#Q.�(�w2����b�"���	"��n٢�+�
����Yx����W2�ai?�^�E�"?�l�Z�S�ܐ9�u���t�� � ��� -yk)z{�7.,���_���jL��(f�%��O�C���֠B��P$1z�%#�v�9,�"���9s�]ZrRW��o�탈Vخ���-�n��:�0��he�Xb\I���$GW7ɽ����6��*,�����J"k�<!K��Y�rbUQ��I��Kl6�K���z%�z��v6H8AP���pEF"�mA,o���.%&75&�GH���!�3�z�r�*�<���X2bD�PE�e7�.6��2O��g����Ɉ��q���-�a?� ��
��k�U�ޒ-�n��־}}~���%)E�%]�.cV�;,e��|���� �J���~��]p+�%�*EY#	y{�f� ��I�6:���dg�s}dC�&���kԭ��.�O>��*]a�I0���!�֐�˴���c�����ܞp����>�e�'���Q���I��sW��ɳz�k�ŵ>'�/�ņ#bNˊ���PL�0�x}	Z�5�敼H��Q�M��f�c˂:��(��iQ߂Þ�4s��NbPk?��������&�G�̛N&����f�;� ��6�;֑���͜F�Ҹ^�㙌�I�!�Y��H���0}9I������+�d0%5�3�+MR�$].���)r�(��[����Z��180��%�������h̨ĉ�a�O%��ɒ{����-K��Ee>R������"��X��/�☾��@��Ӧx3ЪB�'szW��]n��li+"�ɶ�6�6��t�-� кL��H�8D�_�ea�y�t"Jw�a�������M�+P�K��le�x��)q.b���Y��q3�s-�Gl�Rn��T�6R-u����u�YĚ�1�����T�*��TT����V�.����va�r"Tʹ>g#�m���O�N�����ٹ�b]���Z�!���Y���Ki���ڧi�D �E}�
 ��b�=v}�Ůo�2����+��PH|0����Ƕ� ��^��)Tm9*<$��˒�`6��,���c��S�Ĝȏؖ��It_��/R�)����h�4E#�g�䲍8fDJ��HFK5��W/^0�ڟ�]��l�U�7�
��p:I½���`�D�^�'�~xH�����?<9��N�W'���:y_���N�W'������aL��~Ry_���pyx{u��p~GMs�����¥I�Q|�5�S�O�_��f��/�-�{�y#�^�z�)Ќ��d�%w��r����
�����������gWN���y�@o�?_�Kq��/�xn�s�S�U;��r_���v�V��)�:��q��&a`T��g�Z+��?���1�O?��X/�ʢ%��Ua��'���|Ւ�����B�g��P�du�& �B�^⥮�|G���F�l(�
i�^0M��j�9C烧�P�	�1�ٛ��b6�M��!�i�����sa[�7�����V�sl��	��Z��b�D�A�JGf:��h��0
<��?���pU#��͌+j�Q?�Q? `~�����B)>�!�����m%�����M�ͳ}2��$�j�U��)vq$��5�`M/U)��)F����'���N�C �r��)����;PY���D_�.�G�:���?�	����ZP��ER��ӂE�(GςYתA��2f���`��
� US�׊���	F�P-��d���~67�]����TUDpĖ��"�f��Ru/bl�f���b����gK\��!�Ç�:&z���muoH����P�)'�C�~2���F�qq$=U9ϲ~"��/	�mھ,����
�Oۄ�kt=���6�!H�ʕB!i��m�颵��EK��B�M�EP���[��a9i$�!�S��Ru|Q
��Vm��F7sMrK`�ON�.b;�b!���4ot���C�kLڈ���%&+E��,���8|UՕ���X6����q��ˢ�(�������C!H�J�ޝ��d�LlsT�B]�3(k�[7�Җ	�됆y��BP��-�˓�4�GY@�8�͙|6�e"�U���5���5�&��q䵍��ۊm:tRr�K; 3�ĄA�X`ɛ��B���5U����yF����e����[{��)��!!���TRgO�un �a�	K�.\v,��ڀƵG���Z�(��pm��>Br'b��M����v!r��p��Tk-v&�$��R`F�ZCٛ��7AG����Es�r�D�bѩ.b���˓ϙ� �}��0 !����y��ng�
9��-�)OQm����H����d&Wp3��EZ� �k����Və\�%�"�+Sj K0�@�S���k���V0R<�Y0�b(.��Z�di�a�9��.x&a���O���6�<�e��wN"b×���v{�^Y�Qq{V9�A��w��svk,l�DԄ�#-M(��M9��8sS�n"-��g��x��ۧ�-�ȱT�X�#����N����\��Æ��Y/�G������S[��R��n��%����l?��1|������%���qY
����M�Fe�Ȇ|[����8��oY|J͉!�@\Y�X2՝���|��L�Ż��NҤ������.(y���Q:�|��,Bi�O�O�!b$��8*җ6� ד�pK�d�X��5�"�UT��)�6.d�|��薚�ꃶ��OE�4��f�G๭3̐��泣`��f�ݗx<�J�T\n�Î�޾Qx>�;��f>g�!]�sR,7��oYP�����L��BF�B�U���;�OłJ�_��A0F-���C�݁[��ff�����S=z#��mw��m��ȟ���h~p4	ӹxBv�,5K4����ͦ{����	]�
&.��~+��I�=�[��氶���^H�t�d�^#|�C{��(��Eº�����q^���?�?&���s:��IZG���Xx�>+Q�BlG��n �UR>ų.���¡C �	q�dԕa���i�e  ;  ��:��Ʉ��`�s%!��\,���s��H�w\L�JǺt�[q��x�zԺ=8�.����<�ScP>����*�4�1��m���S	����pN���[�X�*��Z�<��ʿq*��UNݤN[':��?����\�C�j���P���	�*�Y��/ʸn�����
6�,�H,%���τ��\.v�w��A^�Z5�s��L��ũbZR6IHΣM�p˖�Sw�`��L����݄V8��fDP|m�w�9ߪ�1`�\I��
�"b]�˻�$�5��4�AషC�O�ͻ|��}���@4�����������Snb ~l8�����������Y⥃"xpfqؙ�aC��t�;L��^�����	k5(���wՍ�4��|��s���'�	�1�"�Rw>E����PL&GAp4�b�k�c��4�;��{�{�����}
%��tW�K����z@G���q<��N�wR��{_�|{������7��J��ߟ��S����ɺz��_�7�1�kS<2KIER��h61���p|:�v��x�|�-�[�E�&�˘�ɽ�O���� Tڕ�[�b��i�#���B�fv�D'�D{m{w��ZbWo%���3��l��
'��u���3ٛ
��De��=�9yoUƺ�f���:b���n���B���!���/����Ocە�֐��@E)��������b!��^�  XA?�TRAȷ'�q�5�0!|*��T�i�!M-d;�c�Ab�5xmKD)�1Q%�tp�*��:޺���
�n9���1b�Bq3�v�j�_��swُ]���h{A'�q
�-�����^=}`�׊�ix%%�c��`D*7]��:V�ה�v�/���i���+-����������RgX^������1���Wk�;	r�i��eӒ
�Wt�$C>���$��	d�K�>#a1`+�>�D�tC8��	��ΠY�mSm�9�g$˷Pú\d҂����
�qm��,��<�3��E�MY�YlĨd[Nӟ�m�iMgp�$�1�Ϊ�Ned�H7XuE�.�Y+l�,��* e#E:n�=m^cE0�"��s����	de2Hp�[�0�n��/�ض�[�������{{s��rb
�>��,�j`6���#�w20���*a_C��R��y��y$RZW��]� �,�'L�B������܀؎C]�>���ܰ1���@$�d%3j%⋌.P��^�ԉe�Ru��JI7��n�щaa�q�I����#&�ݖ�˰���e� ts�eݍ���SG��ES�18�Y��֋{�7Y������J7��j: J`�OM��(���F��i��6�#ݬ�L�~E�V N�n���-ϕ�� ����ʷ;3�}�� \�������-򸎈�8Br�}|��-͌�๣V�����.57�(n葽�AD��s���5��T��G�E9½�Kʥʊ��=x{����vt� 9vf{�=����l*����m]�ԭ�mcͦW��S���E��X/�K�u{��ejUE�%౻��`�MbcӚ1�;��<A���[7Ic�|^DD�
a�iM�n�Օ
s����$Mi�!8���J�ML      C   �   x�}��j�0���S�P�8I��k��ec��֋��FԱ�����x��t|�>$�l�<�+��V�?ƽ�"�vx�G�p�.�B�W�WV)�+W� 9 v����õj�	���dڎ|��O�yv���D�[vm'bq�!zn�o��ᑏݜMw�h9���Hߟ��Z:��@Zs����Zk!�~f,��Ő�x?)�)2���YY�*V�ܠ�ۺ��zY�UU����2��O����      7   ?   x�=��� ���A{�������|�]��?l��|� ��x�k���/;�Y�}      ?   �   x����� C�PE�|(b+H�ul $�\V+!ac3�(9
�8l	�y[2����CԦ�a��Yk:%��6�έC��U����)������x���kk�xQ��� ���Ĭ>�q�	4�ƽ�Q��]��h��E2�e]d<������E�g���`�EQi��8J���+a�      9   {  x�}�Ko�@ ���+z�����{O�Ujm�@nR��c/��!����H=�T��Z��j�Y���[�i +�1�许�B����#�UJH{�$�W
�0��IP�s7��W���cO#CV����Z�!�C��tE�բ.F��ujb��5��s�}�΢���K�7v���̲��܄�E���v�����P�����S;����`�@�Ҍ�Z s��Dr�(��@$@��4�Q�PƢ�i�������T9��a������}��n�T�����I����FG�SK`��&�`��5�pz��'���p�i��R9AB��	�n��������ZIҮ������5ͫ�����I|��<&��q^4e�4�٩)���EO����Ei��������     