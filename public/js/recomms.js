
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
    $scope.pageCount = 1;
    $scope.itemCount = 1;
    $scope.currentPage = 1;
    $scope.currentData = [];
    
    $scope.getProfile = function() { 
        $http.get('/profile/76561197971257137').
            success(function (data) { 
                $scope.profile = data;
                $scope.itemCount = data.length;
                $scope.pageCount = data.length / 20;
                $scope.setPage(1);
            });
    };

    $scope.setPage = function(pageNo) { 
        $scope.currentPage = pageNo;
        var start = (pageNo-1)*20;
        console.log(start);
        $scope.currentData = $scope.profile.slice(start, start+20);
    };
    
    $scope.getProfile();
};

function GenresCtrl($scope, $http) { 
    $scope.pageCount = 1;
    $scope.itemCount = 1;
    $scope.currentPage = 1;
    
    $scope.getSize = function() { 
        $http.get('/genres/size').
            success(function (data) {
                $scope.pageCount = data['pageCount'];
                $scope.itemCount = data['itemCount'];
            });
    };

    $scope.getGenres = function(pageNo) { 
        $http.get('/genres?page='+pageNo).
            success(function (data) { 
                console.log(data);
                $scope.genres = data;
            });
    };
    
    $scope.setPage = function (pageNo) { 
        $scope.currentPage = pageNo;
        $scope.getGenres(pageNo);
    };

    $scope.getSize();
    $scope.setPage(1);
};

function GamesCtrl($scope, $http, gamesService) {
    $scope.pageCount = 1;
    $scope.gameCount = 1;
    $scope.currentPage = 1;
    $scope.maxSize = 10;
    $scope.order = 'total_playtime';
    $scope.header = 'Games';
    $scope.url = '/games';

    var gamesSetup = function(data) { 
        $scope.games = data;
    }
    
    $scope.setPage = function (pageNo) { 
        $scope.currentPage = pageNo;
        gamesService.getGames($scope, $http, '/games',
                pageNo, $scope.order, gamesSetup);
    };

    $scope.getGames = function(order) { 
        gamesService.getGames($scope, $http, '/games', 
                $scope.currentPage, order, gamesSetup);
    };

    gamesService.getSize($scope, $http, '/games/size');
    $scope.setPage(1);
};

function GenreCtrl($scope, $http, $routeParams, gamesService) { 
    $scope.pageCount = 1;
    $scope.gameCount = 1;
    $scope.currentPage = 1;
    $scope.maxSize = 10;
    $scope.order = 'total_playtime';
    $scope.id = $routeParams.id;
    
    var gamesSetup = function(data) { 
        $scope.games = data.games;
        $scope.header = data.name;
    }

    $scope.setPage = function (pageNo) { 
        $scope.currentPage = pageNo;
        gamesService.getGames(
                $scope, $http, '/genres/'+$scope.id, 
                pageNo, $scope.order, gamesSetup);
    };

    $scope.getGames = function(order) { 
        gamesService.getGames(
                $scope, $http, '/genres/'+$scope.id, 
                $scope.currentPage, order, gamesSetup);
    };

    gamesService.getSize($scope, $http, '/genres/'+$scope.id+'/size');
    $scope.setPage(1);
};

