export function debounce(fn, wait){
    let timer;
    return function(...args){
        if(timer) {
            // clear any pre-existing timer
            clearTimeout(timer);
        }
        const context = this;
        // get the current context
        timer = setTimeout(()=>{
            // call the function if time expires
            fn.apply(context, args);
        }, wait);
    }
}