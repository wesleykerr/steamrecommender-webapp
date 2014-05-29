
function NavbarCtrl($scope, $location, SteamIdService) {
    $scope.service = SteamIdService;
    $scope.resetSteam = function() { 
        SteamIdService.reset();
        $location.path('/steamid');
    };
};

function CarouselCtrl($scope) { 
    $scope.myInterval = 5000;
    $scope.slides = [
        {
            image: 'img/game-alt.png',
            header: 'Recommendations',
            text: ' Let us help you decide what game(s) to purchase next from Steam. Our recommendations are made based on what games you own and what games you actively play.',
            btnLink: '#/recomms',
            btnText: 'Get Recommendations' 
        },
        {   
            image: 'img/game2.png',
            header: 'What should I play?',
            text: 'Is your Steam library so large that you are not sure what game you should play next? The technology that helps determine what game you should purchase next can also be used to let you know what game you should play next.',
            btnLink: '#/recomms',
            btnText: 'Get Recommendation'
        },
        {
            image: 'img/game3.png',
            header: 'Steam Game Statistics',
            text: 'Curious to see how popular a game is?  Interested in knowing how long the average player invests in a game?  With your help we can gather these statistics and get a deeper look into the game and how much you played compared to the general population.',
            btnLink: '#/games',
            btnText: 'Games'
        }
    ];
};

function SteamIdCtrl($scope, $http, $location, AppLoading, SteamIdService) { 
    $scope.isCollapsed = true;
    $scope.userEntry = "";
    $scope.showError = true;

    $scope.setSteamId = function(steamId) {
        AppLoading.loading();
        $http.get('/summary/' + steamId).
            success(function (data) { 
                if (data.error) { 
                    console.log(data);
                    AppLoading.ready(true);
                    return;
                }
                console.log(data.players[0]);
                SteamIdService.setSteamId(steamId, data.players[0]);
                $location.path('/profile');
                AppLoading.ready(true);
            }); 
    };

    $scope.searchSteamId = function() { 
        var stringId = "";
        var custom = "http://steamcommunity.com/id/";
        var customURLSet = false;

        var profile = "http://steamcommunity.com/profiles/";
        var profileURLSet = false;

        var steamIdPrefix = "7656119";

        if ($scope.userEntry.slice(0, custom.length) == custom) {
            customURLSet = true;
            stringId = $scope.userEntry(custom.length, $scope.userEntry.length);
        } else if ($scope.userEntry.slice(0, profile.length) == profile) { 
            profileURLSet = true;
            stringId = $scope.userEntry(profile.length, $scope.userEntry.length);
        } else { 
            stringId = $scope.userEntry;
        }
        console.log(stringId);

        // if we are directly setting the steam id, then we
        // should just go forward.
        if (profileURLSet || stringId.slice(0, steamIdPrefix.length) == steamIdPrefix) {
            $scope.setSteamId(stringId);
            return;
        }

        AppLoading.loading();
        $http.get('/resolve/' + stringId).
            success(function (data) { 
                if (data.error || data.success != 1) { 
                    console.log(data);
                    $scope.isCollapsed = false;
                    AppLoading.ready(true);
                    return;
                }
                console.log(data);
                $scope.isCollapsed = true;
                AppLoading.ready(true);
                $scope.setSteamId(data['steamid']);
            });
    };

};

function ProfileCtrl($scope, $http, $routeParams, $location, AppLoading, SteamIdService, ProfileCache) { 
    $scope.state = {};
    $scope.steamDetails = {};
    $scope.getProfile = function() { 
        AppLoading.loading();
        if (!$routeParams.id && !SteamIdService.isReady()) { 
            $location.path('/steamid');
            AppLoading.ready(true);
            return;
        }

        if ($routeParams.id) {
            SteamIdService.setSteamId($routeParams.id);
        }
        $scope.steamDetails = SteamIdService.getSteamDetails();
        var steamId = $scope.steamDetails.steamid;
        var cacheObj = ProfileCache.get(steamId);
        if (cacheObj) {
            $scope.state = {
                profile: cacheObj.profile,
                itemCount: cacheObj.itemCount,
                pageCount: cacheObj.pageCount,
                currentPage: cacheObj.currentPage,
                currentData: cacheObj.currentData
            };
            AppLoading.ready(true);
        } else { 
            $http.get('/profile/' + steamId).
                success(function (data) { 
                    if (data.error && data.id == 1) { 
                        $location.path('/private');
                        AppLoading.ready(true);
                        return;
                    } else if (data.error && data.id == 2) { 
                        $location.path('/connection');
                        AppLoading.ready(true);
                        return;
                    }

                    $scope.state = {
                        profile: data,
                        itemCount: data.length,
                        pageCount: Math.floor(data.length / 20) + 1
                    };
                    $scope.setPage(1);
                    ProfileCache.put(steamId, $scope.state);
                    AppLoading.ready(true);
                });
        }
    };

    $scope.setPage = function(pageNo) { 
        var start = (pageNo-1)*20;
        $scope.state.currentPage = pageNo;
        $scope.state.currentData = $scope.state.profile.slice(start, start+20);
    };
    
    $scope.getProfile();
};

function RecommsCtrl($scope, $http, $location, AppLoading, SteamIdService, RecommsCache) { 
    $scope.state = {};
    $scope.steamDetails = {};
    $scope.getRecomms = function() { 
        AppLoading.loading();
        if (!SteamIdService.isReady()) { 
            $location.path('/steamid');
            AppLoading.ready(true);
            return;
        }

        $scope.steamDetails = SteamIdService.getSteamDetails();
        var steamId = $scope.steamDetails.steamid;
        var cacheObj = RecommsCache.get(steamId);
        if (cacheObj) {
            $scope.state = {
                recommsNew: cacheObj.recommsNew,
                recommsOwned: cacheObj.recommsOwned,
                itemCount: cacheObj.itemCount,
                pageCount: cacheObj.pageCount,
                currentPage: cacheObj.currentPage,
                currentNew: cacheObj.currentNew,
                currentOwned: cacheObj.currentOwned
            };
            AppLoading.ready(true);
        } else { 
            $http.get('/recomms/' + steamId).
                success(function (data) { 
                    if (data.error && data.id == 1) { 
                        $location.path('/private');
                        AppLoading.ready(true);
                        return;
                    } else if (data.error && data.id == 2) { 
                        $location.path('/connection');
                        AppLoading.ready(true);
                        return;
                    }
                    $scope.state = {
                        recommsNew: data.recommsNew,
                        recommsOwned: data.recommsOwned,
                        itemCount: data.recommsNew.length,
                        pageCount: Math.floor(data.recommsNew.length / 20) + 1
                    };
                    $scope.setPage(1);
                    RecommsCache.put(steamId, $scope.state);
                    AppLoading.ready(true);
                });
        }
    };

    $scope.setPage = function(pageNo) { 
        var start = (pageNo-1)*20;
        $scope.state.currentPage = pageNo;
        $scope.state.currentNew = $scope.state.recommsNew.slice(start, start+20);
        $scope.state.currentOwned = $scope.state.recommsOwned.slice(start, start+20);
    };
    
    $scope.getRecomms();
};

function GenresCtrl($scope, $http, AppLoading) { 
    $scope.pageCount = 1;
    $scope.itemCount = 1;
    $scope.currentPage = 1;
    
    $scope.getSize = function() { 
        AppLoading.loading();
        $http.get('/genres/size').
            success(function (data) {
                $scope.pageCount = data['pageCount'];
                $scope.itemCount = data['itemCount'];
                AppLoading.ready();
            });
    };

    $scope.getGenres = function(pageNo) { 
        AppLoading.loading();
        $http.get('/genres?page='+pageNo).
            success(function (data) { 
                $scope.genres = data;
                AppLoading.ready(true);
            });
    };
    
    $scope.setPage = function (pageNo) { 
        $scope.currentPage = pageNo;
        $scope.getGenres(pageNo);
    };

    $scope.getSize();
    $scope.setPage(1);
};

function GameCtrl($scope, $http, $routeParams, AppLoading) { 
    $scope.id = $routeParams.id;
    AppLoading.loading();
    $http.get('games/'+$scope.id).
        success(function (data) {
            $scope.game = data;
            if ($scope.game.owned && $scope.game.not_played) {
                $scope.game.playedGame = $scope.game.owned - $scope.game.not_played;
            }
            AppLoading.ready(true);
        });
};

function ContactCtrl($scope, $http, $location, AppLoading) { 
    $scope.name = "";
    $scope.email = "";
    $scope.message = ""; 

    $scope.sendEmail = function() {
        AppLoading.loading(); 
        var data = { "name": $scope.name, "email": $scope.email, "message": $scope.message };
        console.log(data);
        $http.post('contact', data).
            success(function (data) { 
                AppLoading.ready(true);
                $location.path('/success');
            });
    } 
}

function GamesCtrl($scope, $http, AppLoading, GamesService) {
    $scope.pageCount = 1;
    $scope.gameCount = 1;
    $scope.currentPage = 1;
    $scope.maxSize = 10;
    $scope.order = 'total_playtime';
    $scope.header = 'Games';
    $scope.url = '/games';

    var gamesSetup = function(data) { 
        $scope.games = data;
        AppLoading.ready(true);
    }
    
    $scope.setPage = function (pageNo) { 
        AppLoading.loading();
        $scope.currentPage = pageNo;
        GamesService.getGames($scope, $http, '/games',
                pageNo, $scope.order, gamesSetup);
    };

    $scope.getGames = function(order) { 
        AppLoading.loading();
        GamesService.getGames($scope, $http, '/games', 
                $scope.currentPage, order, gamesSetup);
    };

    GamesService.getSize($scope, $http, '/games/size');
    $scope.setPage(1);
};

function GenreCtrl($scope, $http, $routeParams, AppLoading, GamesService) { 
    $scope.pageCount = 1;
    $scope.gameCount = 1;
    $scope.currentPage = 1;
    $scope.order = 'total_playtime';
    $scope.id = $routeParams.id;
    
    var gamesSetup = function(data) { 
        $scope.games = data.games;
        $scope.header = data.name;
        AppLoading.ready(true);
    }

    $scope.setPage = function (pageNo) { 
        AppLoading.loading();
        $scope.currentPage = pageNo;
        GamesService.getGames(
                $scope, $http, '/genres/'+$scope.id, 
                pageNo, $scope.order, gamesSetup);
    };

    $scope.getGames = function(order) { 
        AppLoading.loading();
        GamesService.getGames(
                $scope, $http, '/genres/'+$scope.id, 
                $scope.currentPage, order, gamesSetup);
    };

    GamesService.getSize($scope, $http, '/genres/'+$scope.id+'/size');
    $scope.setPage(1);
};

