import Link from "@docusaurus/Link"
import useDocusaurusContext from "@docusaurus/useDocusaurusContext"
import useBaseUrl from '@docusaurus/useBaseUrl';
import Layout from "@theme/Layout"
import clsx from "clsx"
import React from "react"
import styles from "./index.module.css"

const FEATURES = [
  {
    title: "Data-Driven",
    description: (
      <>
        Net promotes a Data-Driven design by choice, as opposed to an Event-Driven one.
      </>
    )
  },
  {
    title: "Abstractions & Optimizations",
    description: (
      <>
        No more creating new RemoteEvents, Net handles it all and reduces the Overhead of
        sending RemoteEvent calls.
      </>
    )
  },
  {
    title: "Made for ECS",
    description: (
      <>
        First-Class support for ECS Architectures, made for the Matter ECS.
      </>
    )
  }
]

function Feature({ image, title, description }) {
  return (
    <div className={clsx("col col--4")}>
      {image && (
        <div className="text--center">
          <img className={styles.featureSvg} alt={title} src={image} />
        </div>
      )}
      <div className="text--center padding-horiz--md">
        <h3>{title}</h3>
        <p>{description}</p>
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
          {FEATURES.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  )
}

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext()
  return (
    <header className={clsx("hero", styles.heroBanner)}>
      <div className="container">
        <h1 className="hero__title">{siteConfig.title}</h1>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
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
        <p className={styles.tagline}>
          <h1>
            Networking on Roblox
          </h1>
          Roblox promotes a design behavior where in order to achieve networking, developers must create
          multiple RemoteEvents for each use. This leads to malpractice which results in issues with
          organization and bandwidth.<br />
          <br />
          Networking Modules and Libraries on Roblox strive to fix one of or both of these issues. <a href="https://sleitnick.github.io/Knit/">Knit</a> for example, makes it easier to replicate data and removes the need to make RemoteEvents (though they still exist). And <a href="https://ffrostflame.github.io/BridgeNet2/">BridgeNet2</a> aims to eliminate the need to create multiple RemoteEvents while also optimizing bandwidth.<br />
          <br />
          These are great, except using a framework like Knit is, in most cases, detrimental to developer workflows, and with
          BridgeNet2 and most other Networking Modules and Libraries, they are all flawed by nature, by promoting
          Event-Driven code.<br />
          <br />

          <h1>
            A Data-Driven Networking Library
          </h1>
          When making my switch to ECS, I realized there was no real simple way to handle Networking efficiently in <a href="https://eryn.io/matter/">Matter</a>. Sure, we could use the <code>useEvent</code> function to use RemoteEvents in our code, but this was not efficient and was
          detrimental to organization.<br />
          <br />
          I liked the idea of using BridgeNet2 but I did not like the way it felt when using it in a ECS. So, I decided to
          make my own Networking Library akin to BridgeNet2 but built for use in a ECS.<br />
          <br />
          But why? Well, for some of the same <a href="https://eryn.io/matter/docs/WhyECS">reasons to use a ECS</a>, it felt
          obvious to create and use a Data-Driven Networking Library as opposed to a Event-Driven Networking Library.<br />
          <br />
          <img
            src={useBaseUrl("/BasicUsage.svg")}
            className={styles.codeSnippet}
            align="left"
          /><p>
            <br />
            <br />
            <h2>
              Basic Usage
            </h2>

            Net provides a very simple API for Sending and Querying data, allowing for filtering through QueryParams and simple and efficient Namespacing with Identifiers.<br />
            <br />
            See <a href={useBaseUrl("/docs/intro")}>the Introduction</a> for a more in-depth guide.
          </p>
        </p>
        <div className="container">{/***readme***/}</div>
      </main>
    </Layout>
  )
}