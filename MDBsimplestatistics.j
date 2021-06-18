/*
This file is part of FrACT10, a vision test battery.
Copyright © 2021 Michael Bach, michael.bach@uni-freiburg.de, <https://michaelbach.de>

MDBsimplestatistics.j

2021-04-26  begun
*/


@implementation mdbSimplestatistics


/*
   These functions are  largely unmodified excerpts from »simple-statistics.js« <https://simplestatistics.org/>
   Copyright (c) 2014, Tom MacWright
   simple-statistics is licensed under the ISC License,
   a permissive license leting people do anything with the code with proper attribution and without warranty…
   
   Changes: @example → @ example
   
*/


/**
 * The min is the lowest number in the array.
 * This runs in `O(n)`, linear time, with respect to the length of the array.
 *
 * @param {Array<number>} x sample of one or more data points
 * @throws {Error} if the the length of x is less than one
 * @returns {number} minimum value
 * @ example
 * min([1, 5, -10, 100, 2]); // => -10
 */
function min(x) {
    if (x.length === 0) {
        throw new Error("min requires at least one data point");
    }

    var value = x[0];
    for (var i = 1; i < x.length; i++) {
        if (x[i] < value) {
            value = x[i];
        }
    }
    return value;
}

/**
 * This computes the maximum number in an array.
 *
 * This runs in `O(n)`, linear time, with respect to the length of the array.
 *
 * @param {Array<number>} x sample of one or more data points
 * @returns {number} maximum value
 * @throws {Error} if the the length of x is less than one
 * @ example
 * max([1, 2, 3, 4]);
 * // => 4
 */
function max(x) {
    if (x.length === 0) {
        throw new Error("max requires at least one data point");
    }

    var value = x[0];
    for (var i = 1; i < x.length; i++) {
        if (x[i] > value) {
            value = x[i];
        }
    }
    return value;
}

/**
 * This computes the minimum & maximum number in an array.
 *
 * This runs in `O(n)`, linear time, with respect to the length of the array.
 *
 * @param {Array<number>} x sample of one or more data points
 * @returns {Array<number>} minimum & maximum value
 * @throws {Error} if the the length of x is less than one
 * @ example
 * extent([1, 2, 3, 4]);
 * // => [1, 4]
 */
function extent(x) {
    if (x.length === 0) {
        throw new Error("extent requires at least one data point");
    }

    var min = x[0];
    var max = x[0];
    for (var i = 1; i < x.length; i++) {
        if (x[i] > max) {
            max = x[i];
        }
        if (x[i] < min) {
            min = x[i];
        }
    }
    return [min, max];
}

/**
 * Sampling with replacement is a type of sampling that allows the same
 * item to be picked out of a population more than once.
 *
 * @param {Array<*>} x an array of any kind of value
 * @param {number} n count of how many elements to take
 * @param {Function} [randomSource=Math.random] an optional entropy source that
 * returns numbers between 0 inclusive and 1 exclusive: the range [0, 1)
 * @return {Array} n sampled items from the population
 * @ example
 * var values = [1, 2, 3, 4];
 * sampleWithReplacement(values, 2); // returns 2 random values, like [2, 4];
 */
function sampleWithReplacement(x, n, randomSource) {
    if (x.length === 0) {
        return [];
    }
    
    // a custom random number source can be provided if you want to use
    // a fixed seed or another random number generator, like
    // [random-js](https://www.npmjs.org/package/random-js)
    randomSource = randomSource || Math.random;
    
    var length = x.length;
    var sample = [];
    
    for (var i = 0; i < n; i++) {
        var index = Math.floor(randomSource() * length);
        
        sample.push(x[index]);
    }
    
    return sample;
}


/**
 * The [median](http://en.wikipedia.org/wiki/Median) is
 * the middle number of a list. This is often a good indicator of 'the middle'
 * when there are outliers that skew the `mean()` value.
 * This is a [measure of central tendency](https://en.wikipedia.org/wiki/Central_tendency):
 * a method of finding a typical or central value of a set of numbers.
 *
 * The median isn't necessarily one of the elements in the list: the value
 * can be the average of two elements if the list has an even length
 * and the two central values are different.
 *
 * @param {Array<number>} x input
 * @returns {number} median value
 * @ example
 * median([10, 2, 5, 100, 2, 1]); // => 3.5
 */
function median(x) {
    return +quantile(x, 0.5);
}


/**
 * This is the internal implementation of quantiles: when you know
 * that the order is sorted, you don't need to re-sort it, and the computations
 * are faster.
 *
 * @param {Array<number>} x sample of one or more data points
 * @param {number} p desired quantile: a number between 0 to 1, inclusive
 * @returns {number} quantile value
 * @throws {Error} if p ix outside of the range from 0 to 1
 * @throws {Error} if x is empty
 * @ example
 * quantileSorted([3, 6, 7, 8, 8, 9, 10, 13, 15, 16, 20], 0.5); // => 9
 */
function quantileSorted(x, p) {
    var idx = x.length * p;
    if (x.length === 0) {
        throw new Error("quantile requires at least one data point.");
    } else if (p < 0 || p > 1) {
        throw new Error("quantiles must be between 0 and 1");
    } else if (p === 1) {
        // If p is 1, directly return the last element
        return x[x.length - 1];
    } else if (p === 0) {
        // If p is 0, directly return the first element
        return x[0];
    } else if (idx % 1 !== 0) {
        // If p is not integer, return the next element in array
        return x[Math.ceil(idx) - 1];
    } else if (x.length % 2 === 0) {
        // If the list has even-length, we'll take the average of this number
        // and the next value, if there is one
        return (x[idx - 1] + x[idx]) / 2;
    } else {
        // Finally, in the simple case of an integer value
        // with an odd-length list, return the x value at the index.
        return x[idx];
    }
}


/**
 * Rearrange items in `arr` so that all items in `[left, k]` range are the smallest.
 * The `k`-th element will have the `(k - left + 1)`-th smallest value in `[left, right]`.
 *
 * Implements Floyd-Rivest selection algorithm https://en.wikipedia.org/wiki/Floyd-Rivest_algorithm
 *
 * @param {Array<number>} arr input array
 * @param {number} k pivot index
 * @param {number} [left] left index
 * @param {number} [right] right index
 * @returns {void} mutates input array
 * @ example
 * var arr = [65, 28, 59, 33, 21, 56, 22, 95, 50, 12, 90, 53, 28, 77, 39];
 * quickselect(arr, 8);
 * // = [39, 28, 28, 33, 21, 12, 22, 50, 53, 56, 59, 65, 90, 77, 95]
 */
function quickselect(arr, k, left, right) {
    left = left || 0;
    right = right || arr.length - 1;
    
    while (right > left) {
        // 600 and 0.5 are arbitrary constants chosen in the original paper to minimize execution time
        if (right - left > 600) {
            var n = right - left + 1;
            var m = k - left + 1;
            var z = Math.log(n);
            var s = 0.5 * Math.exp((2 * z) / 3);
            var sd = 0.5 * Math.sqrt((z * s * (n - s)) / n);
            if (m - n / 2 < 0) { sd *= -1; }
            var newLeft = Math.max(left, Math.floor(k - (m * s) / n + sd));
            var newRight = Math.min(
                                    right,
                                    Math.floor(k + ((n - m) * s) / n + sd)
                                    );
            quickselect(arr, k, newLeft, newRight);
        }
        
        var t = arr[k];
        var i = left;
        var j = right;
        
        swap(arr, left, k);
        if (arr[right] > t) { swap(arr, left, right); }
        
        while (i < j) {
            swap(arr, i, j);
            i++;
            j--;
            while (arr[i] < t) { i++; }
            while (arr[j] > t) { j--; }
        }
        
        if (arr[left] === t) { swap(arr, left, j); }
        else {
            j++;
            swap(arr, j, right);
        }
        
        if (j <= k) { left = j + 1; }
        if (k <= j) { right = j - 1; }
    }
}

function swap(arr, i, j) {
    var tmp = arr[i];
    arr[i] = arr[j];
    arr[j] = tmp;
}


/**
 * The [quantile](https://en.wikipedia.org/wiki/Quantile):
 * this is a population quantile, since we assume to know the entire
 * dataset in this library. This is an implementation of the
 * [Quantiles of a Population](http://en.wikipedia.org/wiki/Quantile#Quantiles_of_a_population)
 * algorithm from wikipedia.
 *
 * Sample is a one-dimensional array of numbers,
 * and p is either a decimal number from 0 to 1 or an array of decimal
 * numbers from 0 to 1.
 * In terms of a k/q quantile, p = k/q - it's just dealing with fractions or dealing
 * with decimal values.
 * When p is an array, the result of the function is also an array containing the appropriate
 * quantiles in input order
 *
 * @param {Array<number>} x sample of one or more numbers
 * @param {Array<number> | number} p the desired quantile, as a number between 0 and 1
 * @returns {number} quantile
 * @ example
 * quantile([3, 6, 7, 8, 8, 9, 10, 13, 15, 16, 20], 0.5); // => 9
 */
function quantile(x, p) {
    var copy = x.slice();
    
    if (Array.isArray(p)) {
        // rearrange elements so that each element corresponding to a requested
        // quantile is on a place it would be if the array was fully sorted
        multiQuantileSelect(copy, p);
        // Initialize the result array
        var results = [];
        // For each requested quantile
        for (var i = 0; i < p.length; i++) {
            results[i] = quantileSorted(copy, p[i]);
        }
        return results;
    } else {
        var idx = quantileIndex(copy.length, p);
        quantileSelect(copy, idx, 0, copy.length - 1);
        return quantileSorted(copy, p);
    }
}

function quantileSelect(arr, k, left, right) {
    if (k % 1 === 0) {
        quickselect(arr, k, left, right);
    } else {
        k = Math.floor(k);
        quickselect(arr, k, left, right);
        quickselect(arr, k + 1, k + 1, right);
    }
}

function multiQuantileSelect(arr, p) {
    var indices = [0];
    for (var i = 0; i < p.length; i++) {
        indices.push(quantileIndex(arr.length, p[i]));
    }
    indices.push(arr.length - 1);
    indices.sort(compare);
    
    var stack = [0, indices.length - 1];
    
    while (stack.length) {
        var r = Math.ceil(stack.pop());
        var l = Math.floor(stack.pop());
        if (r - l <= 1) { continue; }
        
        var m = Math.floor((l + r) / 2);
        quantileSelect(
                       arr,
                       indices[m],
                       Math.floor(indices[l]),
                       Math.ceil(indices[r])
                       );
        
        stack.push(l, m, m, r);
    }
}

function compare(a, b) {
    return a - b;
}

function quantileIndex(len, p) {
    var idx = len * p;
    if (p === 1) {
        // If p is 1, directly return the last index
        return len - 1;
    } else if (p === 0) {
        // If p is 0, directly return the first index
        return 0;
    } else if (idx % 1 !== 0) {
        // If index is not integer, return the next index in array
        return Math.ceil(idx) - 1;
    } else if (len % 2 === 0) {
        // If the list has even-length, we'll return the middle of two indices
        // around quantile to indicate that we need an average value of the two
        return idx - 0.5;
    } else {
        // Finally, in the simple case of an integer index
        // with an odd-length list, return the index
        return idx;
    }
}


@end
