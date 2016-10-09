
window.itcast = {};
itcast.transitionEnd = function (objDom, callback) {
    if (typeof objDom != 'object') {
        return false;
    }
    objDom.addEventListener('transitionEnd', function () {
        callback && callback();
    });
    objDom.addEventListener('webkitTransitionEnd', function () {
        callback && callback();
    });
};

window.onload = function () {
    banner();
};
/*轮播图*/
function banner() {
    var banner = document.getElementsByClassName('center_lbt')[0];
    var width = banner.offsetWidth;
    var imagesBox = banner.getElementsByTagName('ul')[0];
    var pointBox = banner.getElementsByTagName('ul')[1];
    var points = pointBox.getElementsByTagName('li');
    var setTranslateX = function (translateX) {
        imagesBox.style.transform = 'translateX(' + translateX + 'px)';
        imagesBox.style.webkitTransform = 'translateX(' + translateX + 'px)';
    }
    var addTransition = function () {
        imagesBox.style.transition = 'all .2s ease';
        imagesBox.style.webkitTransition = 'all .2s ease';
    }
    var removeTransition = function () {
        imagesBox.style.transition = 'none';
        imagesBox.style.webkitTransition = 'none';
    }
    var index = 1;
    var timer;
    timer = setInterval(function () {
        index++;
        addTransition();
        setTranslateX(-index * width);

    }, 2000);
    itcast.transitionEnd(imagesBox, function () {
        if (index >= 3) {
            index = 1;
            removeTransition();
            setTranslateX(-index * width);
        } else if (index <= 0) {
            index = 2;
            removeTransition();
            setTranslateX(-index * width);
        }
        setCurrPoint();
    });

    var setCurrPoint = function () {
        var pointIndex = index;
        if (pointIndex >= 3) {
            pointIndex = 1;
        } else if (index <= 0) {
            pointIndex = 2;
        }
        pointIndex = pointIndex - 1;
        for (var i = 0; i < points.length; i++) {
            points[i].className = " ";
        }
        points[pointIndex].className = "now";
    }
    var startX = 0;/*刚刚触摸屏幕的时候*/
    var moveX = 0;/*滑动的时候的X坐标*/
    var distanceX = 0;/*坐标改变的值*/
    var isMove = false;
    imagesBox.addEventListener('touchstart', function (e) {
        startX = e.touches[0].clientX;
    });
    imagesBox.addEventListener('touchmove', function (e) {
        clearInterval(timer);
        moveX = e.touches[0].clientX;
        distanceX = moveX - startX;
        console.log(distanceX);
        removeTransition();
        setTranslateX(-index * width + distanceX);
        isMove = true;
    });
    window.addEventListener('touchend', function () {
        if (Math.abs(distanceX) > 1 / 3 * width && isMove) {
            if (distanceX > 0) {
                index--;
            } else {
                index++;
            }
            addTransition();
            setTranslateX(-index * width);
        }
        else {
            addTransition();
            setTranslateX(-index * width);
        }
        clearInterval(timer);
        timer = setInterval(function () {
            index++;
            addTransition();

            setTranslateX(-index * width);

        }, 2000);
        startX = 0;
        moveX = 0;
        distanceX = 0;
        isMove = false;

    });
}


