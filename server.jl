using Sockets
using Base.Threads
using Distributed

function fibo(num)
    if num <= 2
        return 1
    end
    return fibo(num-1)+fibo(num -2)
end

function process_fib(client)
    in = readline(client)
    res = try
        fibo(parse(Int, in))
    catch ex
        "Error $ex"
    end
    write(client, string(res)*"\n")

end

function fib_handler(client)
    @info "Thread id $(Threads.threadid())"
    while isopen(client)
         process_fib(client)
    end
    println("Closed")
end

function main()
   port, server = listenany(ip"127.0.0.1", 1234)
   println("Listening on $port")
   @info nprocs()
   reqs = 0
   while true
        sock = accept(server)
        try
            Threads.@spawn fib_handler(sock)
        catch ex
            @info "error" ex
        end
    end
end

main()
