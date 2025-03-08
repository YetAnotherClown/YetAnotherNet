type Recipient = "NET_SERVER" | Player | Player[];

declare class Connection {
	public readonly connected: boolean;

	public disconnect(): void;
	public reconnect(): void;
}

/**
 * Allows for modification of queued packets before they're sent.
 */
declare class SendRequest {
	/**
	 * Modifies the recipients of the packet to the one(s) provided in the parameter.
	 *
	 * @param recipient - The Recipient of the Packet
	 */
	public to(recipient: Recipient): void;
}

type Query<T extends Array<any>> = IterableFunction<LuaTuple<[number, Player | "NET_SERVER", ...T]>>;
type ServerQuery<T extends Array<any>> = IterableFunction<LuaTuple<[number, Player, ...T]>>;
type ClientQuery<T extends Array<any>> = IterableFunction<LuaTuple<[number, ...T]>>;

/**
 * An iterable object returned as the result of `Route.query().client()`.
 *
 * @example
 * ```ts
 * for (const [position, ...T] in Route.query().client()) {
 *     // Do something
 * }
 * ```
 *
 * See [Querying Data](https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/routes#querying) for more information.
 */
type ClientQueryResult<T extends Array<any>> = ClientQuery<T>;

/**
 * An iterable object returned as the result of `Route.query().server()` that can filter snapshots
 * by Players.
 *
 * @example
 * ```ts
 * for (const [position, player, ...T] in Route.query().server()) {
 *     // Do something
 * }
 * ```
 *
 * See [Querying Data](https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/routes#querying) for more information.
 */
type ServerQueryResult<T extends Array<any>> = ServerQuery<T> & {
	/**
	 * Filters Packets from the QueryResult's Snapshot based on the provided Senders.
	 *
	 * @param recipients - The Recipients of the Packet
	 */
	from(...recipients: Array<Player>): ServerQueryResult<T>;
};

/**
 * An iterable object returned as the result of `Route.query()` that can filter snapshots
 * by Identifier and Senders.
 *
 * @example
 * ```ts
 * for (const [position, sender, ...T] in Route.query()) {
 *     // Do something
 * }
 * ```
 *
 * See [Querying Data](https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/routes#querying) for more information.
 */
type QueryResult<T extends Array<any>> = Query<T> & {
	/**
	 * Filters Packets from the QueryResult's Snapshot based on the provided Senders.
	 *
	 * @param recipient - The Recipients of the Packet
	 */
	from(...recipient: Array<Recipient>): QueryResult<T>;
	/**
	 * Switches the query to a client view, for typechecking.
	 * The client view will not return a `sender` when iterating.
	 *
	 * @returns ClientQueryResult
	 */
	client(): ClientQueryResult<T>;
	/**
	 * Switches the query to a server view, for typechecking.
	 *
	 * @returns ServerQueryResult
	 */
	server(): ServerQuery<T>;
};

declare namespace Net {
	const server: "NET_SERVER";

	type Configuration = {
		Channel: "Reliable" | "Unreliable" | undefined;
		Event: string | undefined;
	};

	class Route<T extends Array<any>> {
		public constructor(configuration?: Configuration);

		/**
		 * Sends data to all clients or to specific recipients from the Route's identifier.
		 *
		 * By default, `Net.send()` will send the data to all Clients. You can specify which
		 * Clients to receive the data by chaining `Route.send().to(recipient)` and passing
		 * `[Player]`, ``Player`, or ``Net.server`.
		 *
		 * See [Sending Data](https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/routes#sending) for more information.
		 *
		 * @returns SendRequest - A chainable object for modifying the send request
		 */
		public send(...data: T): SendRequest;

		/**
		 * Allows for iteration of all packets of the previous frame.
		 * You can filter by Senders by chaining the `QueryResult:from()` method onto the query method.
		 *
		 * See [Querying Data](https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/routes#querying) for more information.
		 *
		 * @returns QueryResult - A query of packets from that frame
		 */
		public query(): QueryResult<T>;

		/**
		 * Sets a function to be ran on Incoming packets before they are processed.
		 * For example, this would run after the Client receives a Packet from the Server over the network:
		 * after calling `Route.send()` on the Server and before calling `Route.query()` on the Client.
		 *
		 * See [Middleware](https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/middleware) for more information.
		 *
		 * @param middleware - A function that transforms your data
		 */
		public addIncomingMiddleware(
			middleware: (...rawData: Array<unknown>) => LuaTuple<T> | LuaTuple<any> | undefined
		): void;

		/**
		 * Sets a function to be ran on Outgoing packets before they are sent over the network.
		 * For example, this would run before the Server sends a Packet to the Client over the network:
		 * after calling `Route.send()` on the Server and before the Client ever receives the Packet.
		 *
		 * See [Middleware](https://yetanotherclown.github.io/YetAnotherNet/docs/getting-started/middleware) for more information.
		 *
		 * @param middleware - A function that transforms your data
		 */
		public addOutgoingMiddleware(middleware: (...rawData: T | any) => LuaTuple<any> | undefined): void;
	}

	/**
	 * Initializes your Routes by adding middleware to your Matter Loop.
	 * This ensures that your Routes run between each frame.
	 *
	 * ### Note
	 *
	 * Please make sure that the event you set in the Configuration, or the default,
	 * is the same index you used for your `RunService.Heartbeat` event in your `Loop:begin()` method.
	 *
	 * Your Routes are meant to run on the heartbeat, like most systems.
	 * In some cases you may want to run your Routes on different events,
	 * in this case it is acceptable to change it to a different event.
	 */
	function start(loop: any, routes: { [index: string]: Route<any> }): void;

	/**
	 * This function allows you to run the scheduling code on your own events.
	 *
	 * Because scheduling should be ran at the beginning and end of each frame,
	 * this will return two functions which you can use to call the scheduling code for the beginning and end of a frame.
	 *
	 * @example
	 * ```ts
	 * import { RunService } from "@rbxts/services";
	 *
	 * import Net from "@rbxts/yetanothernet";
	 * import routes from "shared/routes";
	 *
	 * const myRoute = routes.myRoute;
	 *
	 * const [beginFrame, endFrame] = Net.createHook(routes);
	 * RunService.Heartbeat.Connect(() => {
	 *     beginFrame();
	 *
	 *     myRoute.send(...)
	 *     for (const [pos, sender, ...] of myRoute.query()) {
	 *         // Do something
	 *     }
	 *
	 *     endFrame();
	 * });
	 * ```
	 *
	 * @param routes - An array of your routes
	 */
	function createHook(routes: { [index: string]: Route<any> }): LuaTuple<[() => void, () => void]>;

	/**
	 * Creates a connection to allow you to use Routes as if they were Signals.
	 *
	 * This method of reading data from Routes should be considered second-class.
	 * The use of Route.query() in a loop will always be first-class.
	 *
	 * Connections will always be called on the end of frame when using YetAnotherNet.createHook()
	 * or YetAnotherNet.start(), but will be called in the order they are received on the client.
	 *
	 * It is only suggested that you use these if you are working outside of a loop or outside
	 * of an ECS system.
	 *
	 * @param route - The Route to observe
	 * @param callback - The callback to run
	 * @returns Connection
	 */
	function createConnection<T extends Array<any>>(
		route: Route<T>,
		callback: (i: number, sender: Player | "NET_SERVER", ...data: T) => void
	): Connection;
}

export = Net;
