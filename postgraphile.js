const express = require("express");
const { postgraphile } = require("postgraphile");
const jwt = require("express-jwt");

const postgraphileOptions = {
  subscriptions: true,
  watchPg: true,
  dynamicJson: true,
  setofFunctionsContainNulls: false,
  ignoreRBAC: false,
  /**
   * Filter plugin doesn't pickup the combo indexes on tstzrange properly
   */
  ignoreIndexes: true,
  showErrorStack: "json",
  extendedErrors: ["hint", "detail", "errcode"],
  appendPlugins: [
    require("@graphile-contrib/pg-simplify-inflector"),
    require("postgraphile-plugin-connection-filter"),
    /**
     * This is a fork of postgraphile-plugin-fulltext-filter
     */
    require("@pyramation/postgraphile-plugin-fulltext-filter"),
  ],
  exportGqlSchemaPath: "schema.graphql",
  graphiql: true,
  graphiqlRoute: "/",
  enhanceGraphiql: true,
  allowExplain(req) {
    return true;
  },
  enableQueryBatching: true,
  legacyRelations: "omit",
  pgSettings(req) {
    const settings = {
      statement_timeout: "300",
      role: "anonymous",
    };

    if (req.user) {
      settings["user.id"] = req.user.sub;
      settings["role"] = "authenticated_user";
    }

    return settings;
  },
};

// const checkJwt = jwt({
//   secret: process.env.JWT_SECRET,
//   audience: process.env.JWT_AUDIENCE,
//   issuer: `https://${process.env.AUTH0_DOMAIN}/`,
//   algorithms: ["RS256"],
// });

// const authErrors = (err, req, res, next) => {
//   if (err.name === "UnauthorizedError") {
//     console.log(err);

//     res.status(err.status).json({ errors: [{ message: err.message }] });

//     res.end();
//   }
// };

const app = express();

// app.use("/graphql", checkJwt);
// app.use("/graphql", authErrors);

app.use(postgraphile(process.env.DATABASE_URL, "public", postgraphileOptions));

const PORT = 3000;
const HOST = "0.0.0.0";

app.listen(PORT, HOST);

console.log(`Running on http://${HOST}:${PORT}`);
