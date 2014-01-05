
recommApp = angular
    .module('recommender', ['ngAnimate', 'ngRoute', 'ngCookies', 'ui.bootstrap'])
    .config(['$routeProvider', function($routeProvider) {
        $routeProvider.
          when('/home', {templateUrl: 'partials/home.html', controller: CarouselCtrl }).
          when('/about', {templateUrl: 'partials/about.html' }).
          when('/contact', {templateUrl: 'partials/contact.html', controller: ContactCtrl }).
          when('/success', {templateUrl: 'partials/success.html' }).
          when('/private', {templateUrl: 'partials/private.html'}).
          when('/connection', {templateUrl: 'partials/connection.html'}).
          when('/profile', {templateUrl: 'partials/profile.html', controller: ProfileCtrl }).
          when('/profile/:id', {templateUrl: 'partials/profile.html', controller: ProfileCtrl }).
          when('/recomms', {templateUrl: 'partials/recomms.html', controller: RecommsCtrl }).
          when('/steamid', {templateUrl: 'partials/steamid.html', controller: SteamIdCtrl }).
          when('/games', { templateUrl: 'partials/games.html', controller: GamesCtrl}).
          when('/game/:id', { templateUrl: 'partials/game.html', controller: GameCtrl}).
          when('/genres', { templateUrl: 'partials/genres.html', controller: GenresCtrl }).
          when('/genre/:id', { templateUrl: 'partials/genre.html', controller: GenreCtrl }).
          otherwise({redirectTo: '/home'});
    }]);

recommApp.factory('AppLoading', function($rootScope) { 
    var timer;
    return { 
        loading : function() { 
            clearTimeout(timer);
            $rootScope.status = 'loading';
            if (!$rootScope.$$phase) $rootScope.$apply();
        },
        ready : function(delay) { 
            function ready() { 
                $rootScope.status = 'ready';
                if (!$rootScope.$$phase) $rootScope.$apply();
            }

            clearTimeout(timer);
            delay = delay == null ? 5000 : false;
            if (delay) { 
                timer = setTimeout(ready, delay);
            } else { 
                ready();
            }
        }
    };
});

recommApp.directive('game', function() { 
    return { 
        restrict: 'E',
        templateUrl: 'partials/game-directive.html'
    };
});

recommApp.factory('ProfileCache', function($cacheFactory) { 
   return $cacheFactory('profile');
});

recommApp.factory('RecommsCache', function($cacheFactory) { 
   return $cacheFactory('recomms');
});

recommApp.service('SteamIdService', function($cookies) { 
    var steamId = 'Steam Id';
    var ready = false;

    this.isReady = function() { 
        return ready;
    };

    this.reset = function() { 
        steamId = 'Steam Id';
        delete $cookies.steamId;
        ready = false;
    };

    this.setSteamId = function(newSteamId) { 
        steamId = newSteamId;
        $cookies.steamId = steamId;
        ready = true;
    };

    this.getSteamId = function() { 
        return steamId;
    };

    this.init = function() { 
        var cookieValue = $cookies.steamId;
        if (cookieValue) {
            steamId = cookieValue;
            ready = true;
        } else { 
            steamId = 'Steam Id';
            ready = false;
        }
    };

    this.init();
});

recommApp.service("GamesService", function(AppLoading) { 
    this.getSize = function(state, http, url) {
        AppLoading.loading();
        http.get(url).
            success(function (data) {
                state.pageCount = data['pageCount'];
                state.gameCount = data['gameCount'];
                AppLoading.ready(5000);
            });
    };

    this.getGames = function(state, http, prefix, pageNo, order, fn) { 
        state.pageNo = pageNo;
        state.order = order;
        http.get(prefix+'?page='+pageNo+'&order='+order).success(fn);
    };
});


