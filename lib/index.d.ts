type Recipient = "NET_SERVER" | Player | [Player]

/**
 * Allows for modification of queued packets before they're sent.
 */
declare class SendRequest {
    /**
     * Modifies the recipients of the packet to the one(s) provided in the parameter.
     * @param recipient - The Recipient of the Packet
    */
    public to(recipient: Recipient): void;
}

type Query<T extends Array<any>> = IterableFunction<LuaTuple<[number, Player | "NET_SERVER", ...T]>>;

/**
     * An iterable object returned as the result of `Route.query()` that can filter snapshots
     * by Identifier and Senders.
     * 
     * @example
     * ```ts
     * for (const [position, sender, ...T] in Route.query()) {
     *  // Do something
     * }
     * ```
    */
type QueryResult<T extends Array<any>> = Query<T> & {
    /**
     * Filters Packets from the QueryResult's Snapshot based on the provided Senders.
     * @param recipient - The Recipient of the Packet
    */
    from(...recipient: Array<Recipient>): QueryResult<T>;
}

declare namespace Net {
    const server: "NET_SERVER";

    type Configuration = {
        Channel: "Reliable" | "Unreliable" | undefined,
        Event: string | undefined,
    }

    class Route<T extends Array<any>> {
        public constructor(configuration: Configuration | null);

        /**
         * Sends data to all clients or to specific recipients from the Route's identifier.
         * By default, `Net.send()` will send the data to all Clients. You can specify which
         * Clients to receive the data by chaining `Route.send().to(recipient)` and passing
         * ``[Player]``, ``Player``, or ``Net.server``.
         * 
         * See [Sending Data](https://yetanotherclown.github.io/Net/docs/getting-started/routes#sending) for more information.
         * @returns SendRequest - A chainable object for modifying the send request
        */
        public send(...data: T): SendRequest;

        /**
         * Allows for iteration of all packets of the previous frame.
         * You can filter by Senders by chaining the ``QueryResult.from()`` method onto the query method.
         * @returns QueryResult - A query of packets from that frame
        */
        public query(): QueryResult<T>;

        /**
         * Sets a function to be ran on Incoming packets before they are processed.
         * For example, this would run after the Client receives a Packet from the Server over the network:
         * after calling ``Route.send()`` on the Server and before calling ``Route.query()`` on the Client.
         * 
         * See [Middleware](https://yetanotherclown.github.io/Net/docs/getting-started/middleware) for more information.
         * @param middleware - A function that transforms your data
         */
        public addIncomingMiddleware(middleware: (...rawData: Array<unknown>) => LuaTuple<T> | undefined): void

        /**
         * Sets a function to be ran on Outgoing packets before they are sent over the network.
         * For example, this would run before the Server sends a Packet to the Client over the network:
         * after calling ``Route.send()`` on the Server and before the Client ever receives the Packet.
         * 
         * See [Middleware](https://yetanotherclown.github.io/Net/docs/getting-started/middleware) for more information.
         * @param middleware - A function that transforms your data
         */
        public addOutgoingMiddleware(middleware: (...rawData: T) => LuaTuple<any> | undefined): void
    }

    /**
     * Initializes your Routes by adding middleware to your Matter Loop.
     * This ensures that your Routes run between each frame.
     * 
     * Please make sure that the event you set in the Configuration, or the default,
     * is the same index you used for your ``RunService.Heartbeat`` event in your
     * ``Loop.begin()`` method.
     * 
     * Your Routes are meant to run on the heartbeat, like most systems.
     * In some cases you may want to run your Routes on different events,
     * in this case it is acceptable to change it to a different event.
     * @param loop - A Matter Loop
     * @param routes - An array of your routes
     */
    function start(loop: any, routes: {[index: string]: Route<any>}): void
    /**
     * This function allows you to run Net scheduling code on your own events.
     * 
     * When you provide a table of Routes, this function will return another function
     * you can call which will step each Route and process it's Packet Queue.
     * 
     * For example, to run scheduling on the Heartbeat:
     * ```ts
     * const hook = Net.createHook(routes);
     * RunService.Heartbeat.Connect(hook)
     * ```
     * @param routes - An array of your routes
     */
    function createHook(routes: {[index: string]: Route<any>}): () => void
}

export = Net