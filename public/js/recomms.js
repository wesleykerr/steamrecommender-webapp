
function NavbarCtrl($scope) {

    $scope.steamId = "Steam Id";
    $scope.ready = false;
    $scope.resetSteam = function() { 
        console.log("resetSteam called");
        $scope.steamId = "Steam Id";
        $scope.ready = false;
    };

};

function CarouselCtrl($scope) { 
    $scope.myInterval = 5000;
    $scope.slides = [
        {
            image: 'img/game-alt.png',
            header: 'Recommendations',
            text: ' Let us help you decide what game(s) to purchase next from Steam. Our recommendations are made based on what games you own and what games you actively play.',
            btnLink: '/recomms',
            btnText: 'Get Recommendations' 
        },
        {   
            image: 'img/game2.png',
            header: 'What should I play?',
            text: 'Is your Steam library so large that you are not sure what game you should play next? The technology that helps determine what game you should purchase next can also be used to let you know what game you should play next.',
            btnLink: '/recomms',
            btnText: 'Get Recommendation'
        },
        {
            image: 'img/game3.png',
            header: 'Steam Game Statistics',
            text: 'Curious to see how popular a game is?  Interested in knowing how long the average player invests in a game?  With your help we can gather these statistics and get a deeper look into the game and how much you played compared to the general population.',
            btnLink: '/games',
            btnText: 'Games'
        }
    ];
};

function ProfileCtrl($scope, $http) { 
};

function GamesCtrl($scope, $http) {
    $scope.getGames = function() { 
        $http.get('/games').
            success(function (data) { 
                $scope.games = data;
                console.log(data);
            });
    };

    $scope.getGames();
};

function RecommsCtrl($scope, $http, championService, dragonService, filterService, recommsService) { 
    $scope.summonerName = 'deerslyr1';
    $scope.filterOwned = false;
    $scope.filterPlayed = true;
    $scope.modelIds = ['crm_3', 'crm_4', 'crm_5', 'crm_6', 'crm_7', 'crm_8', 'crm_0', 'crm_1', 'crm_2'];
    $scope.recommendations = {};
    
    championService.getChampions($scope, $http);

    $scope.getRecomms = function() { 
        var apiSummonerName = $scope.summonerName.toLowerCase().replace(" ", "");
        var url = "/legs/playersearch/summonername?platform=NA1&summonerName=" + apiSummonerName;
        $http.get(url).
            success(function (data) { 
                $scope.accountId = data[0].accountId;
                annotateInstance($scope.accountId);
                for (var i in $scope.modelIds) {
                    recomms($scope.accountId, $scope.modelIds[i]);
                }
            }).
            error(function(data, status, headers, config) { 
                console.log(data);
                console.log(status);
                console.log(headers);
            });
    };

    var annotateInstance = function(accountId) { 
        var url = "/api/annotations/summoner_owned_played/annotate";
        $http.post(url, { 'dreco_id': accountId+':NA1' }).
            success(function (data) { 
                console.log(data);
                $scope.itemsPlayed = {};
                $scope.championsPlayed = [];
                for (var champ in data.played.champion) { 
                    if ($scope.championMap[champ] == null)
                        continue;
                    $scope.itemsPlayed[champ] = true;
                    $scope.championsPlayed.push(createChampionObj(champ, data.played.champion[champ]));
                }

                $scope.skinsPlayed = [];
                for (var skin in data.played.skin) { 
                    $scope.itemsPlayed[skin] = true;
                    $scope.skinsPlayed.push(createSkinObj(skin, data.played.skin[skin]));
                }

                $scope.itemsOwned = {};
                $scope.championsOwned = [];
                for (var champIndex in data.owned.champion) { 
                    var champ = data.owned.champion[champIndex];
                    if ($scope.championMap[champ] == null)
                        continue;
                    $scope.itemsOwned[champ] = true;
                    $scope.championsOwned.push(createChampionObj(champ, 0));
                }

                $scope.skinsOwned = [];
                for (var skinIndex in data.owned.skin) { 
                    var skin = data.owned.skin[skinIndex];
                    $scope.itemsOwned[skin] = true;
                    $scope.skinsOwned.push(createSkinObj(skin, 0));
                }
            });
    };

    var createChampionObj = function(champ, score) { 
        var obj = {};
        obj['id'] = champ;
        obj['name'] = $scope.championMap[champ];
        obj['score'] = score;
        obj['imgSrc'] = dragonService.url() + obj['name'] + "_0.jpg";
        return obj;
    };

    var createSkinObj = function(skin, score) { 
        var obj = {};
        var id = parseInt(skin);
        obj['id'] = skin;
        obj['championId'] = Math.floor(id / 1000);
        obj['skinIndex'] = id % 1000;
        obj['name'] = $scope.championMap[obj['championId']];
        obj['imgSrc'] = dragonService.url() + obj['name'] + "_" + obj['skinIndex'] + '.jpg';
        obj['score'] = score;
        return obj;
    };

    var recomms = function(accountId, modelId) { 
        var url = '/api/models/' + modelId + '/recommendation?nrecs=1000';
        $http.post(url, { 'dreco_id': accountId+':NA1' }).
            success(function (data) { 
                if (data.recommendations.length == 0)
                    return;
               
                results = filterService.filterUnknownedChampion($scope.itemsOwned, data.recommendations); 
                if ($scope.filterOwned)
                    results = filterService.filter($scope.itemsOwned, results);
                if ($scope.filterPlayed)
                    results = filterService.filter($scope.itemsPlayed, results);

                $scope.recommendations[modelId] = recommsService.create(results, $scope.championMap, dragonService.url()).slice(0,5);
            });
    };
}

function ChampionsCtrl($scope, $http, championService, dragonService, filterService, recommsService) { 
    championService.getChampions($scope, $http);

    $scope.championsSelected = {};
    $scope.champions = [];
    $scope.filterSkins = false;
    $scope.modelIds = ['crm_3', 'crm_4', 'crm_5', 'crm_6', 'crm_7', 'crm_8', 'crm_0', 'crm_1', 'crm_2'];
    $scope.recommendations = {};

    $scope.clearChampions = function() { 
        $scope.championsSelected = {};
    };
    
    var createChampionObj = function(champ, score) { 
        var obj = {};
        obj['id'] = champ;
        obj['name'] = $scope.championMap[champ];
        obj['score'] = score;
        obj['imgSrc'] = dragonService.url() + obj['name'] + "_0.jpg";
        return obj;
    };

    $scope.getRecomms = function() { 
        $scope.champions = [];
        var postObj = { 'dreco_id': 'MISSING:NONE', 'played': { 'champion': {}, 'skin': {} } };
        Object.keys($scope.championsSelected).forEach(function(key) { 
            if ($scope.championsSelected[key]) { 
                postObj.played.champion[$scope.championNameToId[key]] = 1;
                $scope.champions.push(createChampionObj($scope.championNameToId[key], 1));
            }
        });
        console.log(postObj);
        for (var i in $scope.modelIds) {
            recomms($scope.modelIds[i], postObj);
        }
    };
    
    var recomms = function(modelId, postObj) { 
        var url = '/api/models/' + modelId + '/recommendation?nrecs=1000';
        console.log(postObj);
        $http.post(url, postObj).
            success(function (data) { 
                if (data.recommendations == null || data.recommendations.length == 0)
                    return;

                results = filterService.filter(postObj.played.champion, data.recommendations);
                if ($scope.filterSkins) 
                    results = filterService.filterSkins(results);
                $scope.recommendations[modelId] = recommsService.create(results, $scope.championMap, dragonService.url()).slice(0,5);
            });
    };
}
