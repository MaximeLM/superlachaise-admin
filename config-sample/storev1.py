from superlachaise.models import *

def get_node_id_mappings_export_object(config):
    mappings = StoreV1NodeIDMapping.objects.exclude(wikidata_entry=None)
    return {
        "about": {
            "source": "http://www.openstreetmap.org/",
            "license": "http://www.openstreetmap.org/copyright/",
        },
        "storev1_node_id_mappings": [get_node_id_mapping_export_object(mapping) for mapping in mappings],
    }

def get_node_id_mapping_export_object(mapping):
    return {
        "id": mapping.id,
        "wikidata_entry": mapping.wikidata_entry.id,
    }

NODE_ID_MAPPINGS = [
    {
        "id": 2649596674,
        "wikidata_entry": "Q29643006"
    },
    {
        "id": 1668264337,
        "wikidata_entry": "Q3323370"
    },
    {
        "id": 2628689416,
        "wikidata_entry": "Q275003"
    },
    {
        "id": 2697001973,
        "wikidata_entry": "Q2339515"
    },
    {
        "id": 2647658051,
        "wikidata_entry": "Q390367"
    },
    {
        "id": 2707952426,
        "wikidata_entry": "Q2853642"
    },
    {
        "id": 2728217039,
        "wikidata_entry": "Q3559456"
    },
    {
        "id": 1915793658,
        "wikidata_entry": "Q133855"
    },
    {
        "id": 2697001976,
        "wikidata_entry": "Q152793"
    },
    {
        "id": 2649520651,
        "wikidata_entry": "Q154353"
    },
    {
        "id": 2663061680,
        "wikidata_entry": "Q130519"
    },
    {
        "id": 1915793687,
        "wikidata_entry": "Q75603"
    },
    {
        "id": 2765555550,
        "wikidata_entry": "Q1347677"
    },
    {
        "id": 1915793659,
        "wikidata_entry": "Q9711"
    },
    {
        "id": 2628752275,
        "wikidata_entry": "Q18404"
    },
    {
        "id": 2674707235,
        "wikidata_entry": "Q333843"
    },
    {
        "id": 2663272254,
        "wikidata_entry": "Q15168424"
    },
    {
        "id": 2636802288,
        "wikidata_entry": "Q545477"
    },
    {
        "id": 2765555522,
        "wikidata_entry": "Q29650332"
    },
    {
        "id": 2647533741,
        "wikidata_entry": "Q3163651"
    },
    {
        "id": 2647508388,
        "wikidata_entry": "Q590823"
    },
    {
        "id": 2663238386,
        "wikidata_entry": "Q170209"
    },
    {
        "id": 2663278344,
        "wikidata_entry": "Q208230"
    },
    {
        "id": 2663253477,
        "wikidata_entry": "Q361976"
    },
    {
        "id": 2636798252,
        "wikidata_entry": "Q4605"
    },
    {
        "id": 2707975863,
        "wikidata_entry": "Q3189365"
    },
    {
        "id": 2610749877,
        "wikidata_entry": "Q964297"
    },
    {
        "id": 1915793654,
        "wikidata_entry": "Q56158"
    },
    {
        "id": 2647668766,
        "wikidata_entry": "Q355112"
    },
    {
        "id": 2636792813,
        "wikidata_entry": "Q309722"
    },
    {
        "id": 2674711259,
        "wikidata_entry": "Q1450807"
    },
    {
        "id": 2628667096,
        "wikidata_entry": "Q15163097"
    },
    {
        "id": 2697001984,
        "wikidata_entry": "Q15163584"
    },
    {
        "id": 2663064041,
        "wikidata_entry": "Q274251"
    },
    {
        "id": 2649513478,
        "wikidata_entry": "Q945890"
    },
    {
        "id": 2674645790,
        "wikidata_entry": "Q15163781"
    },
    {
        "id": 2663248136,
        "wikidata_entry": "Q442937"
    },
    {
        "id": 2697001968,
        "wikidata_entry": "Q2977082"
    },
    {
        "id": 1915793657,
        "wikidata_entry": "Q15168755"
    },
    {
        "id": 2767821688,
        "wikidata_entry": "Q3348869"
    },
    {
        "id": 2628700824,
        "wikidata_entry": "Q658479"
    },
    {
        "id": 2647618163,
        "wikidata_entry": "Q295144"
    },
    {
        "id": 2661227175,
        "wikidata_entry": "Q290045"
    },
    {
        "id": 2674665708,
        "wikidata_entry": "Q70326"
    },
    {
        "id": 2647611429,
        "wikidata_entry": "Q3323374"
    },
    {
        "id": 2697001969,
        "wikidata_entry": "Q55375"
    },
    {
        "id": 2707975860,
        "wikidata_entry": "Q1961152"
    },
    {
        "id": 2649590704,
        "wikidata_entry": ""
    },
    {
        "id": 1915793662,
        "wikidata_entry": "Q260"
    },
    {
        "id": 2672737600,
        "wikidata_entry": "Q361305"
    },
    {
        "id": 2610835772,
        "wikidata_entry": "Q708011"
    },
    {
        "id": 2663264334,
        "wikidata_entry": "Q15181960"
    },
    {
        "id": 1915793639,
        "wikidata_entry": "Q392352"
    },
    {
        "id": 2697001982,
        "wikidata_entry": "Q366057"
    },
    {
        "id": 2697001972,
        "wikidata_entry": "Q3080698"
    },
    {
        "id": 2649545062,
        "wikidata_entry": "Q218679"
    },
    {
        "id": 1915793627,
        "wikidata_entry": "Q12718"
    },
    {
        "id": 2672739322,
        "wikidata_entry": "Q123089"
    },
    {
        "id": 2628742111,
        "wikidata_entry": "Q2661519"
    },
    {
        "id": 2765555539,
        "wikidata_entry": "Q3188496"
    },
    {
        "id": 2649582567,
        "wikidata_entry": "Q148475"
    },
    {
        "id": 2636786218,
        "wikidata_entry": "Q22075397"
    },
    {
        "id": 2610815702,
        "wikidata_entry": "Q51107"
    },
    {
        "id": 2649521612,
        "wikidata_entry": "Q326434"
    },
    {
        "id": 2647558151,
        "wikidata_entry": "Q785956"
    },
    {
        "id": 1915793655,
        "wikidata_entry": "Q171969"
    },
    {
        "id": 2707975862,
        "wikidata_entry": "Q1429885"
    },
    {
        "id": 2611013418,
        "wikidata_entry": "Q165910"
    },
    {
        "id": 2647629281,
        "wikidata_entry": "Q213526"
    },
    {
        "id": 2663325709,
        "wikidata_entry": "Q228546"
    },
    {
        "id": 2636809035,
        "wikidata_entry": "Q3490902"
    },
    {
        "id": 2649584809,
        "wikidata_entry": "Q187506"
    },
    {
        "id": 2647652534,
        "wikidata_entry": "Q83155"
    },
    {
        "id": 2674657654,
        "wikidata_entry": "Q158778"
    },
    {
        "id": 2765555528,
        "wikidata_entry": "Q346913"
    },
    {
        "id": 2728421146,
        "wikidata_entry": "Q15912691"
    },
    {
        "id": 2647610304,
        "wikidata_entry": "Q1069399"
    },
    {
        "id": 1915793636,
        "wikidata_entry": "Q33477"
    },
    {
        "id": 2663070197,
        "wikidata_entry": "Q15181590"
    },
    {
        "id": 2674739418,
        "wikidata_entry": "Q3189752"
    },
    {
        "id": 2697001977,
        "wikidata_entry": "Q91706"
    },
    {
        "id": 2672744457,
        "wikidata_entry": "Q3531119"
    },
    {
        "id": 2628701846,
        "wikidata_entry": "Q377790"
    },
    {
        "id": 1915793660,
        "wikidata_entry": "Q483512"
    },
    {
        "id": 2661279723,
        "wikidata_entry": "Q679098"
    },
    {
        "id": 2647644925,
        "wikidata_entry": "Q77177"
    },
    {
        "id": 1915793684,
        "wikidata_entry": "Q154842"
    },
    {
        "id": 2728336401,
        "wikidata_entry": "Q2849294"
    },
    {
        "id": 2628703942,
        "wikidata_entry": "Q319927"
    },
    {
        "id": 2649537764,
        "wikidata_entry": "Q15166738"
    },
    {
        "id": 2649522565,
        "wikidata_entry": "Q296076"
    },
    {
        "id": 2728251815,
        "wikidata_entry": "Q2086266"
    },
    {
        "id": 2661275349,
        "wikidata_entry": "Q1296217"
    },
    {
        "id": 1915793661,
        "wikidata_entry": "Q8772"
    },
    {
        "id": 2672746767,
        "wikidata_entry": "Q633498"
    },
    {
        "id": 1915793625,
        "wikidata_entry": "Q187241"
    },
    {
        "id": 2728217032,
        "wikidata_entry": "Q2413117"
    },
    {
        "id": 2672677620,
        "wikidata_entry": "Q601266"
    },
    {
        "id": 2663334649,
        "wikidata_entry": "Q708596"
    },
    {
        "id": 2663328243,
        "wikidata_entry": "Q153185"
    },
    {
        "id": 2672718054,
        "wikidata_entry": "Q192428"
    },
    {
        "id": 2636786649,
        "wikidata_entry": "Q518827"
    },
    {
        "id": 2647591862,
        "wikidata_entry": "Q106443"
    },
    {
        "id": 2661273250,
        "wikidata_entry": "Q18168585"
    },
    {
        "id": 2628673749,
        "wikidata_entry": "Q532852"
    },
    {
        "id": 2707952440,
        "wikidata_entry": "Q347652"
    },
    {
        "id": 2628659819,
        "wikidata_entry": "Q247603"
    },
    {
        "id": 2611019171,
        "wikidata_entry": "Q206244"
    },
    {
        "id": 2636915286,
        "wikidata_entry": "Q19282236"
    },
    {
        "id": 2728217035,
        "wikidata_entry": "Q333821"
    },
    {
        "id": 2611016394,
        "wikidata_entry": "Q379699"
    },
    {
        "id": 2672703663,
        "wikidata_entry": "Q3323379"
    },
    {
        "id": 2649571368,
        "wikidata_entry": "Q184212"
    },
    {
        "id": 2672673026,
        "wikidata_entry": "Q157056"
    },
    {
        "id": 2649538218,
        "wikidata_entry": "Q191798"
    },
    {
        "id": 2610756342,
        "wikidata_entry": "Q315017"
    },
    {
        "id": 2636910105,
        "wikidata_entry": ""
    },
    {
        "id": 2707952441,
        "wikidata_entry": "Q761853"
    },
    {
        "id": 2649548127,
        "wikidata_entry": "Q3148168"
    },
    {
        "id": 2636806656,
        "wikidata_entry": "Q2121322"
    },
    {
        "id": 2663346214,
        "wikidata_entry": "Q2299673"
    },
    {
        "id": 2697001987,
        "wikidata_entry": "Q15839337"
    },
    {
        "id": 2649576067,
        "wikidata_entry": "Q23380"
    },
    {
        "id": 2707952421,
        "wikidata_entry": "Q14660072"
    },
    {
        "id": 2636788643,
        "wikidata_entry": "Q3188690"
    },
    {
        "id": 2610764311,
        "wikidata_entry": "Q155415"
    },
    {
        "id": 2663293469,
        "wikidata_entry": "Q138105"
    },
    {
        "id": 2649578701,
        "wikidata_entry": "Q2087624"
    },
    {
        "id": 2707989161,
        "wikidata_entry": "Q477747"
    },
    {
        "id": 2661217171,
        "wikidata_entry": "Q3323381"
    },
    {
        "id": 2765555544,
        "wikidata_entry": "Q1346280"
    },
    {
        "id": 2765555563,
        "wikidata_entry": "Q1218474"
    },
    {
        "id": 2610813547,
        "wikidata_entry": "Q233088"
    },
    {
        "id": 2636914748,
        "wikidata_entry": "Q1327266"
    },
    {
        "id": 2663047981,
        "wikidata_entry": "Q29642996"
    },
    {
        "id": 2661300067,
        "wikidata_entry": "Q707712"
    },
    {
        "id": 2649521135,
        "wikidata_entry": "Q1382222"
    },
    {
        "id": 2697001971,
        "wikidata_entry": "Q273797"
    },
    {
        "id": 2697001967,
        "wikidata_entry": "Q2870577"
    },
    {
        "id": 1915793642,
        "wikidata_entry": "Q209169"
    },
    {
        "id": 2661295342,
        "wikidata_entry": "Q193257"
    },
    {
        "id": 2707952445,
        "wikidata_entry": "Q298784"
    },
    {
        "id": 2672732737,
        "wikidata_entry": "Q2602308"
    },
    {
        "id": 2697001979,
        "wikidata_entry": "Q157191"
    },
    {
        "id": 2628703851,
        "wikidata_entry": "Q182192"
    },
    {
        "id": 2765555547,
        "wikidata_entry": "Q3107581"
    },
    {
        "id": 2674654592,
        "wikidata_entry": "Q242609"
    },
    {
        "id": 2647605835,
        "wikidata_entry": "Q212639"
    },
    {
        "id": 2647601121,
        "wikidata_entry": "Q310791"
    },
    {
        "id": 2728251813,
        "wikidata_entry": "Q1630239"
    },
    {
        "id": 1915793626,
        "wikidata_entry": "Q120993"
    },
    {
        "id": 2661217314,
        "wikidata_entry": "Q3323385"
    },
    {
        "id": 2611062155,
        "wikidata_entry": "Q3484051"
    },
    {
        "id": 2663284611,
        "wikidata_entry": "Q206832"
    },
    {
        "id": 1915793663,
        "wikidata_entry": "Q24265482"
    },
    {
        "id": 1915599876,
        "wikidata_entry": "Q3426652"
    },
    {
        "id": 2636903827,
        "wikidata_entry": "Q993521"
    },
    {
        "id": 1152422864,
        "wikidata_entry": "Q910923"
    },
    {
        "id": 2661230415,
        "wikidata_entry": "Q151173"
    },
    {
        "id": 2649540770,
        "wikidata_entry": "Q179680"
    },
    {
        "id": 2647640675,
        "wikidata_entry": "Q152272"
    },
    {
        "id": 2636930182,
        "wikidata_entry": "Q40116"
    },
    {
        "id": 2647545902,
        "wikidata_entry": "Q191305"
    },
    {
        "id": 2672740946,
        "wikidata_entry": "Q40756"
    },
    {
        "id": 2674700627,
        "wikidata_entry": "Q6050"
    },
    {
        "id": 2610818875,
        "wikidata_entry": "Q963719"
    },
    {
        "id": 2610995399,
        "wikidata_entry": "Q714788"
    },
    {
        "id": 2707975865,
        "wikidata_entry": "Q3531847"
    },
    {
        "id": 2661255940,
        "wikidata_entry": "Q11984907"
    },
    {
        "id": 2611015834,
        "wikidata_entry": "Q55410"
    },
    {
        "id": 2661284154,
        "wikidata_entry": "Q15860323"
    },
    {
        "id": 2628681072,
        "wikidata_entry": "Q18168599"
    },
    {
        "id": 2636933479,
        "wikidata_entry": "Q266561"
    },
    {
        "id": 2661221799,
        "wikidata_entry": "Q360312"
    },
    {
        "id": 470258150,
        "wikidata_entry": "Q284683"
    },
    {
        "id": 2707952436,
        "wikidata_entry": "Q372750"
    },
    {
        "id": 2663261502,
        "wikidata_entry": "Q317155"
    },
    {
        "id": 1915793634,
        "wikidata_entry": "Q1631"
    },
    {
        "id": 2628712746,
        "wikidata_entry": "Q661825"
    },
    {
        "id": 1915793628,
        "wikidata_entry": "Q134741"
    },
    {
        "id": 2697001985,
        "wikidata_entry": "Q374912"
    },
    {
        "id": 2636824054,
        "wikidata_entry": "Q3159783"
    },
    {
        "id": 2663076376,
        "wikidata_entry": "Q314019"
    },
    {
        "id": 2707975864,
        "wikidata_entry": "Q3340690"
    },
    {
        "id": 2610732003,
        "wikidata_entry": "Q455878"
    },
    {
        "id": 2661299096,
        "wikidata_entry": "Q191408"
    },
    {
        "id": 2728251814,
        "wikidata_entry": "Q510334"
    },
    {
        "id": 2649587194,
        "wikidata_entry": "Q1362889"
    },
    {
        "id": 1915793682,
        "wikidata_entry": "Q15206039"
    },
    {
        "id": 2663014267,
        "wikidata_entry": "Q267985"
    },
    {
        "id": 2697001981,
        "wikidata_entry": "Q3351318"
    },
    {
        "id": 2663285709,
        "wikidata_entry": "Q682230"
    },
    {
        "id": 2697001988,
        "wikidata_entry": "Q3569177"
    },
    {
        "id": 2661305216,
        "wikidata_entry": "Q289163"
    },
    {
        "id": 2663040532,
        "wikidata_entry": "Q29643243"
    },
    {
        "id": 2649516984,
        "wikidata_entry": "Q334983"
    },
    {
        "id": 2649542252,
        "wikidata_entry": "Q9726"
    },
    {
        "id": 2661325764,
        "wikidata_entry": "Q922667"
    },
    {
        "id": 2674649194,
        "wikidata_entry": "Q82934"
    },
    {
        "id": 2661277628,
        "wikidata_entry": "Q2958353"
    },
    {
        "id": 2628713048,
        "wikidata_entry": "Q318060"
    },
    {
        "id": 2674662092,
        "wikidata_entry": "Q3323377"
    },
    {
        "id": 2707975861,
        "wikidata_entry": "Q3140480"
    },
    {
        "id": 2649568041,
        "wikidata_entry": "Q120417"
    },
    {
        "id": 2636925573,
        "wikidata_entry": "Q319261"
    },
    {
        "id": 1915793656,
        "wikidata_entry": "Q34013"
    },
    {
        "id": 2663312801,
        "wikidata_entry": "Q294344"
    },
    {
        "id": 2663032295,
        "wikidata_entry": "Q15161337"
    },
    {
        "id": 2663065605,
        "wikidata_entry": "Q1335349"
    },
    {
        "id": 2765555534,
        "wikidata_entry": "Q2031275"
    },
    {
        "id": 2765555559,
        "wikidata_entry": "Q286475"
    },
    {
        "id": 2628678445,
        "wikidata_entry": "Q188385"
    },
    {
        "id": 2672700210,
        "wikidata_entry": "Q274886"
    },
    {
        "id": 2661232516,
        "wikidata_entry": "Q316518"
    },
    {
        "id": 2766437732,
        "wikidata_entry": "Q1357659"
    },
    {
        "id": 2649562990,
        "wikidata_entry": "Q5738"
    },
    {
        "id": 2628699258,
        "wikidata_entry": "Q345408"
    },
    {
        "id": 2663348467,
        "wikidata_entry": "Q905267"
    },
    {
        "id": 2728217037,
        "wikidata_entry": "Q2110802"
    },
    {
        "id": 2636809297,
        "wikidata_entry": "Q325453"
    },
    {
        "id": 2618160979,
        "wikidata_entry": "Q15156042"
    },
    {
        "id": 2707952423,
        "wikidata_entry": "Q2850778"
    },
    {
        "id": 2636809415,
        "wikidata_entry": "Q235641"
    },
    {
        "id": 2636855002,
        "wikidata_entry": "Q302580"
    },
    {
        "id": 2628694965,
        "wikidata_entry": "Q3372335"
    },
    {
        "id": 2647664510,
        "wikidata_entry": "Q551597"
    },
    {
        "id": 2697001975,
        "wikidata_entry": "Q3157334"
    },
    {
        "id": 2696996999,
        "wikidata_entry": "Q3554585"
    },
    {
        "id": 2610721232,
        "wikidata_entry": "Q3098317"
    },
    {
        "id": 2649543430,
        "wikidata_entry": "Q15166260"
    },
    {
        "id": 1915793690,
        "wikidata_entry": "Q468618"
    },
    {
        "id": 2674732708,
        "wikidata_entry": "Q15160973"
    },
    {
        "id": 1915793689,
        "wikidata_entry": "Q12432989"
    },
    {
        "id": 2636826745,
        "wikidata_entry": "Q29642948"
    },
    {
        "id": 2611008485,
        "wikidata_entry": "Q340260"
    },
    {
        "id": 2628698194,
        "wikidata_entry": "Q152176"
    }
]
