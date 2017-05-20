from superlachaise.models import *

def get_category_export_object(config):
    categories = Category.objects.all()
    return {
        "categories": {category.id: get_single_category_export_object(category, config.base.LANGUAGES) for category in categories if category.id != "ignore"},
    }

def get_single_category_export_object(category, languages):
    export_object = {
        "id": category.id,
        "localizations": {},
    }

    labels = category.labels()
    for language in languages:
        export_object["localizations"][language] = {
            "label": labels[language],
        } if language in labels else None

    return export_object

CATEGORIES = [
    {
        "id": "art",
        "labels": {
            "en": "art",
            "fr": "art"
        },
        "wikidata_categories": [
            "Q1028181",
            "Q11569986",
            "Q1281618",
            "Q15296811",
            "Q15472169",
            "Q173950",
            "Q1925963",
            "Q4164507",
            "Q483501"
        ]
    },
    {
        "id": "cinema",
        "labels": {
            "en": "cinema",
            "fr": "cinéma"
        },
        "wikidata_categories": [
            "Q10800557",
            "Q1415090",
            "Q222344",
            "Q2526255",
            "Q28389",
            "Q2962070",
            "Q3282637",
            "Q4220892"
        ]
    },
    {
        "id": "ignore",
        "labels": {
            "en": "ignore",
            "fr": "ignore"
        },
        "wikidata_categories": [
            "Q105186",
            "Q10732476",
            "Q11481802",
            "Q12020057",
            "Q1209498",
            "Q121594",
            "Q1225716",
            "Q1229025",
            "Q1234713",
            "Q1297719",
            "Q131524",
            "Q133485",
            "Q13418253",
            "Q13472585",
            "Q14089670",
            "Q1420621",
            "Q14623005",
            "Q1475726",
            "Q15212951",
            "Q15627169",
            "Q15632632",
            "Q15895020",
            "Q15962340",
            "Q15981151",
            "Q16031530",
            "Q1622272",
            "Q16533",
            "Q16947657",
            "Q17307272",
            "Q175151",
            "Q1792450",
            "Q18120029",
            "Q182436",
            "Q185351",
            "Q18805",
            "Q18939491",
            "Q19435686",
            "Q1979607",
            "Q211423",
            "Q2114605",
            "Q212980",
            "Q214970",
            "Q22272441",
            "Q222836",
            "Q2259532",
            "Q23305046",
            "Q2358549",
            "Q2516866",
            "Q2576499",
            "Q2640827",
            "Q2664701",
            "Q266569",
            "Q2860259",
            "Q3055126",
            "Q3068305",
            "Q3128486",
            "Q329439",
            "Q33231",
            "Q333634",
            "Q33999",
            "Q3488528",
            "Q3499072",
            "Q355242",
            "Q3579035",
            "Q37226",
            "Q40348",
            "Q43845",
            "Q4504549",
            "Q4610556",
            "Q55187",
            "Q635734",
            "Q650012",
            "Q691522",
            "Q7042855",
            "Q728425",
            "Q7358",
            "Q806798",
            "Q80687",
            "Q81096",
            "Q8178443",
            "Q860918",
            "Q885122",
            "Q901222",
            "Q957729",
            "Q974144"
        ]
    },
    {
        "id": "literature",
        "labels": {
            "en": "literature",
            "fr": "littérature"
        },
        "wikidata_categories": [
            "Q11774202",
            "Q15949613",
            "Q18814623",
            "Q18844224",
            "Q3064032",
            "Q3589290",
            "Q36180",
            "Q4263842",
            "Q482980",
            "Q4853732",
            "Q49757",
            "Q623386",
            "Q6625963",
            "Q864380"
        ]
    },
    {
        "id": "medias",
        "labels": {
            "en": "medias",
            "fr": "médias"
        },
        "wikidata_categories": [
            "Q1114448",
            "Q15978391",
            "Q1607826",
            "Q1930187",
            "Q2722764",
            "Q3024627",
            "Q3658608",
            "Q578109",
            "Q947873"
        ]
    },
    {
        "id": "men",
        "labels": {
            "en": "men",
            "fr": "hommes"
        },
        "wikidata_categories": [
            "Q6581097"
        ]
    },
    {
        "id": "military",
        "labels": {
            "en": "military",
            "fr": "armée"
        },
        "wikidata_categories": [
            "Q189290",
            "Q47064",
            "Q4991371",
            "Q9352089"
        ]
    },
    {
        "id": "music",
        "labels": {
            "en": "music",
            "fr": "musique"
        },
        "wikidata_categories": [
            "Q1259917",
            "Q12800682",
            "Q13391399",
            "Q14915627",
            "Q158852",
            "Q16145150",
            "Q17093672",
            "Q177220",
            "Q27514986",
            "Q2865819",
            "Q36834",
            "Q3922505",
            "Q486748",
            "Q488205",
            "Q6168364",
            "Q639669",
            "Q753110",
            "Q822146",
            "Q855091"
        ]
    },
    {
        "id": "performing_arts",
        "labels": {
            "en": "performing arts",
            "fr": "spectacle vivant"
        },
        "wikidata_categories": [
            "Q15855449",
            "Q16023925",
            "Q1760363",
            "Q2490358",
            "Q5716684",
            "Q674067",
            "Q7622988"
        ]
    },
    {
        "id": "philosophy",
        "labels": {
            "en": "philosophy",
            "fr": "philosophie"
        },
        "wikidata_categories": [
            "Q4964182"
        ]
    },
    {
        "id": "politics",
        "labels": {
            "en": "politics",
            "fr": "politique"
        },
        "wikidata_categories": [
            "Q1780490",
            "Q193391",
            "Q82955"
        ]
    },
    {
        "id": "research",
        "labels": {
            "en": "research",
            "fr": "recherche scientifique"
        },
        "wikidata_categories": [
            "Q10872101",
            "Q11063",
            "Q13416354",
            "Q1350189",
            "Q1371378",
            "Q14467526",
            "Q14565331",
            "Q15632482",
            "Q16271261",
            "Q1662561",
            "Q169470",
            "Q170790",
            "Q1781198",
            "Q188094",
            "Q201788",
            "Q205375",
            "Q2306091",
            "Q2310145",
            "Q2374149",
            "Q350979",
            "Q3621491",
            "Q39631",
            "Q4773904",
            "Q520549",
            "Q593644",
            "Q864503",
            "Q901"
        ]
    },
    {
        "id": "sport",
        "labels": {
            "en": "sport",
            "fr": "sport"
        },
        "wikidata_categories": [
            "Q14085739",
            "Q15958185"
        ]
    },
    {
        "id": "theatre",
        "labels": {
            "en": "theatre",
            "fr": "théâtre"
        },
        "wikidata_categories": [
            "Q214917",
            "Q2259451",
            "Q245068",
            "Q3387717"
        ]
    },
    {
        "id": "urbanism",
        "labels": {
            "en": "urban planning",
            "fr": "urbanisme"
        },
        "wikidata_categories": [
            "Q13582652",
            "Q42973"
        ]
    },
    {
        "id": "women",
        "labels": {
            "en": "women",
            "fr": "femmes"
        },
        "wikidata_categories": [
            "Q6581072"
        ]
    }
]
