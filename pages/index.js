import Link from "@docusaurus/Link"
import useDocusaurusContext from "@docusaurus/useDocusaurusContext"
import Layout from "@theme/Layout"
import clsx from "clsx"
import React from "react"
import styles from "./index.module.css"
import { func } from "prop-types"

const FEATURES = [
  {
    image: "Routes.svg",
    title: "Routes",
    description: (
      <body>
        <p>
          Routes are the way you send and receive data through YetAnotherNet.
          They are uniquely identified so you're encouraged to create as many as you need as if you were creating individual RemoteEvents.
        </p>
        <p>
          Routes can be Reliable or Unreliable.
          Reliable events are never dropped and are always in order per frame.
          Unreliable events might be dropped on bad connections, but they are always received in order per frame.
        </p>
        <p>
          You can also strictly type Routes to get autocompletion and typechecking when Sending and Querying packets.
        </p>
      </body>
    )
  },
  {
    image: "Middleware.svg",
    title: "Middleware",
    description: (
      <body>
        <p>
          Middleware is another powerful feature of YetAnotherNet, allowing you to validate types before they reach your code.
        </p>
        <p>
          To create Middleware, you set a function in your Route's Middleware that will give you the event <code lang="lua">"send" | "receive"</code> and the data
          that is about to be processed <code lang="lua">U...</code>, the types you specify in your type annotation <code lang="lua">Net&lt;U...&gt;</code>
        </p>
        <p>
          In the Middleware function, you can validate your types. If your data does not match your types, you can do <code lang="lua">return nil</code> to drop the packet.
          Dropped packets will never reach your code, meaning you can ensure that the types your code receives are always the types you expect.
        </p>
        <p>
          You may want to use Middleware to Compress or Decompress your data, but YetAnotherNet has built-in buffer compression!
        </p>
      </body>
    )
  },
  {
    image: "Hooks.svg",
    title: "Hooks",
    description: (
      <body>
        <p>
          Hooks are a simple and versatile way to integrate YetAnotherNet into any code architecture.
        </p>
        <p>
          Hooks allow you to run your Route's scheduling whenever you want, such as a specific event.
          A Hook is simply a function that you can call which will run each Route's scheduling code to process the current frame.
          Data is not sent over the Network until your hook is called.
        </p>
        <p>
          YetAnotherNet also provides a simple function that hooks your Routes to your Matter Middleware to run before/after your systems.
          This allows for a simple setup when using the Matter ECS, leaving you to not worry about scheduling your Routes.
        </p>
      </body>
    )
  }
]

function Feature({ image, title, description }) {
  return (
    <div class={styles.feature}>
      <div class={styles.featureImage}>
        <img src={image} />
      </div>
      <div class={styles.featureText}>
        <h1>{title}</h1>
        <>{description}</>
      </div>
    </div>
  )
}

export function HomepageFeatures() {
  if (!FEATURES) return null

  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          <div className={styles.feature}>
            <div style={{ paddingLeft: 30, maxWidth: "45%" }}>
              <h1>A Type-safe Networking Library</h1>
              <p>
                YetAnotherNet is strictly-typed, giving you full auto-completion and type-safety.
              </p>
              <p>
                Send arguments and Query return values of your Routes are fully typed, giving you auto-completion and type-checking when writing your Networking code.
              </p>
            </div>
            <div style={{ paddingLeft: 100 }}>
              <h1>Hassle-free Compression Included</h1>
              <p>
                YetAnotherNet works behind the scenes to automatically compress the data you send over the network.
                It features an internal Ser/Des library to serialize all Luau Datatypes and most Roblox Datatypes.
              </p>
              <p>
                This process requires no work on the user's end besides making sure to avoid
                any <a href="./docs/getting-started/buffer-compression#unsupported-datatypes">Unsupported Datatypes</a>.
              </p>
            </div>
          </div>
        </div>
        <div className="row">
          <div className={styles.feature}>
          <div style={{ paddingLeft: 30, maxWidth: "45%" }}>
              <h1>Data-driven by Design</h1>
              <p>
                With it's roots in ECS, YetAnotherNet was designed to promote a Data-driven design.<br />
                YetAnotherNet's API integrates seamlessly into ECS Libraries like Matter to bring Data-driven Networking in ECS architectures.
              </p>
              <p>
                Read more on why you should use an ECS <a href="https://matter-ecs.github.io/matter/docs/WhyECS">here</a>.
              </p>
            </div>
            <div style={{ paddingLeft: 60}}>
              <h1>Available for Roblox Typescript</h1>
                <p>
                We provide Typings for Roblox Typescript users, you can get them on NPM <a href="https://www.npmjs.com/package/@rbxts/yetanothernet">here</a>,
                or you can install using <code>npm i @rbxts/yetanothernet</code>.
                </p>
            </div>
          </div>
        </div>
        <div className="row">
          {FEATURES.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section >
  )
}

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext()
  const bannerImage = siteConfig.customFields.bannerImage
  const hasBannerImage = bannerImage ? true : false
  const heroBannerStyle = hasBannerImage ? { backgroundImage: `url("${bannerImage}")` } : null

  const titleClassName = clsx("hero__title", {
    [styles.titleOnBannerImage]: hasBannerImage
  })
  const taglineClassName = clsx("hero__subtitle", {
    [styles.taglineOnBannerImage]: hasBannerImage
  })

  return (
    <header className={clsx("hero", styles.heroBanner)} style={heroBannerStyle}>
      <div className="container">
        <img
          alt="YetAnotherNet — A Data-Driven Networking Library, inspired by Bevy_Renet & BridgeNet2, made for ECS."
          src="Banner.svg"
        ></img>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro"
          >
            Get Started →
          </Link>
        </div>
      </div>
    </header>
  )
}

export default function Home() {
  const { siteConfig, tagline } = useDocusaurusContext()
  return (
    <Layout title={siteConfig.title} description={tagline}>
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  )
}