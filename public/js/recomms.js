
function NavbarCtrl($scope, $location, SteamIdService) {
    $scope.service = SteamIdService;
    $scope.resetSteam = function() { 
        console.log("resetSteam called");
        SteamIdService.reset();
        $location.path('/steamid');
    };

    $scope.$watch('service.getSteamId()', function(newVal) { 
        $scope.steamId = newVal;
    });
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

function SteamIdCtrl($scope, $location, SteamIdService) { 
    $scope.steamId = "";
    $scope.setSteamId = function() {
        SteamIdService.setSteamId($scope.steamId);
        $location.path('/profile');
    };
};

function ProfileCtrl($scope, $http, $location, AppLoading, SteamIdService, ProfileCache) { 
    $scope.state = {};
    $scope.$watch('state.pageCount', function(newValue, oldValue, scope) { 
        console.log('State Changed: ' + $scope.state.pageCount); 
    });
    
    $scope.getProfile = function() { 
        AppLoading.loading();
        if (!SteamIdService.isReady()) { 
            $location.path('/steamid');
            AppLoading.ready(true);
            return;
        }

        var steamId = SteamIdService.getSteamId();
        var cacheObj = ProfileCache.get(steamId);
        if (cacheObj) {
            console.log('cache hit');
            console.log(cacheObj);
            $scope.state = {
                profile: cacheObj.profile,
                itemCount: cacheObj.itemCount,
                pageCount: cacheObj.pageCount,
                currentPage: cacheObj.currentPage,
                currentData: cacheObj.currentData
            };
            console.log($scope.state);
            AppLoading.ready(true);
        } else { 
            console.log('cache miss');
            $http.get('/profile/' + steamId).
                success(function (data) { 
                    $scope.state = {
                        profile: data,
                        itemCount: data.length,
                        pageCount: Math.floor(data.length / 20) + 1
                    };
                    $scope.setPage(1);
                    ProfileCache.put(steamId, $scope.state);
                    console.log($scope.state);
                    console.log('ready');
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
    $scope.$watch('state.pageCount', function(newValue, oldValue, scope) { 
        console.log('State Changed: ' + $scope.state.pageCount); 
    });
    
    $scope.getRecomms = function() { 
        AppLoading.loading();
        if (!SteamIdService.isReady()) { 
            $location.path('/steamid');
            AppLoading.ready(true);
            return;
        }

        var steamId = SteamIdService.getSteamId();
        var cacheObj = RecommsCache.get(steamId);
        if (cacheObj) {
            console.log('cache hit');
            console.log(cacheObj);
            $scope.state = {
                recommsNew: cacheObj.recommsNew,
                recommsOwned: cacheObj.recommsOwned,
                itemCount: cacheObj.itemCount,
                pageCount: cacheObj.pageCount,
                currentPage: cacheObj.currentPage,
                currentNew: cacheObj.currentNew,
                currentOwned: cacheObj.currentOwned
            };
            console.log($scope.state);
            AppLoading.ready(true);
        } else { 
            console.log('cache miss');
            $http.get('/recomms/' + steamId).
                success(function (data) { 
                    $scope.state = {
                        recommsNew: data.recommsNew,
                        recommsOwned: data.recommsOwned,
                        itemCount: data.recommsNew.length,
                        pageCount: Math.floor(data.recommsNew.length / 20) + 1
                    };
                    $scope.setPage(1);
                    RecommsCache.put(steamId, $scope.state);
                    console.log($scope.state);
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
                console.log(data);
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
            console.log($scope.game);
        });
};

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

function GenreCtrl($scope, $http, $routeParams, GamesService) { 
    $scope.pageCount = 1;
    $scope.gameCount = 1;
    $scope.currentPage = 1;
    $scope.maxSize = 10;
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

