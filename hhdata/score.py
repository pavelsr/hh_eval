groups_dict = {
    "python": "dev",
    "django": "dev",
    "flask": "dev",
    "fastapi": "dev",
    "asyncio": "dev",
    "github": "dev",
    "leetcode": "dev", #*
    "скрипт": "dev",
    "парсер": "dev",
    "реверс": "reverse",
    "wireshark": "reverse", #*
    "android": "reverse",
    "декомпимляц": "reverse",
    "OSINT": "reverse",
    "tensorflow": "ml", #*
    "scikit": "ml",     #*
    "pytorch": "ml",
    "scipy": "ml",
    "opencv": "ml",
    "нейросет": "ml",
    "pandas": "ml",
    "numpy": "ml",
    "kagle": "ml",
    "docker": "devops", #*
    "CentOS": "devops",
    "Debian": "devops",
    "Ubuntu": "devops",
    "Figma": "design",  #*
    "GIMP": "design",
    "Inkscape": "design",
    "Photoshop": "design",
    "Corel": "design",
    "дизайн": "design",
    "HTML": "design",
    "CSS": "design",
    "Selenium": "qa",
}

top_words = [
    'leetcode',
    'fastapi',
    'AsyncIO',
    'Figma',
    'Inkscape',
    'GIMP',
    'wireshark',
    'tensorflow'
    'scikit'
    'pytorch'
    'scipy',
    'opencv',
    'raspberrypi',
    'хакатон'
]

def get_groups_str(text, groups_dict):
    '''
    Классифицирует произвольный текст по группам, соответствующим ключевым словам

    Пример: get_groups_str("python selenium", groups_dict)
    '''
    keysList = list(groups_dict.keys())
    groups = []
    for word in keysList:
        if re.search(word, text, re.IGNORECASE):
            groups.append(groups_dict[word])
    groups = set(groups)
    groups = list(groups)
    return ",".join(groups)

def get_keywords_str(text, wordsList):
    words = []
    for word in wordsList:
        if re.search(word, text, re.IGNORECASE):
            words.append(word)
    return ",".join(words)


def get_keywords_str_from_dict(text, groups_dict):
    '''
    Выделяет ключевые слова из произвольного текста простым грепом

    Пример: get_keywords_str("i like python, but also I use wireshark", groups_dict)
    '''
    keysList = list(groups_dict.keys())
    words = []
    for word in keysList:
        if re.search(word, text, re.IGNORECASE):
            words.append(word)
    words = set(words)
    words = list(words)
    return ",".join(words)

def scoreit(df):
    df['keywords'] = df['all_text'].apply(lambda x: get_keywords_str_from_dict(x, groups_dict))
    df['keywords_count'] = df['all_text'].apply(lambda x: sum([x.count(word) for word in list(groups_dict.keys())])).astype("Int32")

    df['possible_groups'] = df['all_text'].apply(lambda x: get_groups_str(x, groups_dict))
    df['possible_groups_count'] = df['possible_groups'].apply(lambda x: x.count(",") + 1).astype("Int32")

    df['top_words'] = df['all_text'].apply(lambda x: get_keywords_str(x, top_words))
    df['top_words_count'] = df['top_words'].apply(lambda x: x.count(",") + 1).astype("Int32")

    df['is_cover_not_mass'] = df['cover_letter_text'].apply(lambda x: 1 if "стажировк".upper() in x.upper() else 0)
    df['is_unix_way'] = df['all_text'].apply(lambda x: 1 if "linux".upper() in x.upper() else 0)
    df['is_know_english'] = df['english_level'].apply(lambda x: 1 if x else 0)

    en_lvl_dict = { 'a1':1, 'a2':2, 'b1':3, 'b2':4, 'c1':5, 'c2':6 }
    df['english_level_int'] = df['english_level'].apply(lambda x: en_lvl_dict[x] if x in list(en_lvl_dict.keys()) else 0)

    df['score_1'] = df.possible_groups_count/df.possible_groups_count.max()
    + df.keywords_count/df.keywords_count.max()
    + df.top_words_count/df.top_words_count.max()
    + df.english_level_int/df.english_level_int.max()
    + df.experience_months/df.experience_months.max()

    return df
