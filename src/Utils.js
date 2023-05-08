export function debounce(fn, wait){
    let timer;
    return function(...args){
        if(timer) {
            // clear any pre-existing timer
            clearTimeout(timer);
        }

        // get the current context
        timer = setTimeout(()=>{
            // call the function if time expires
            fn.apply(this, args);
        }, wait);
    }
}