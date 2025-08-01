import middy from '@middy/core'
import ssm from '@middy/ssm'

import { DynamoDB } from '@aws-sdk/client-dynamodb'
import { DynamoDBDocumentClient, ScanCommand } from '@aws-sdk/lib-dynamodb'

const dynamodbClient = new DynamoDB()
const dynamodb = DynamoDBDocumentClient.from(dynamodbClient)

const { service_name, stage_name } = process.env
const tableName = process.env.restaurants_table

const getRestaurants = async (count) => {
  console.log(`fetching ${count} restaurants from ${tableName}...`)

  const resp = await dynamodb.send(new ScanCommand({
    TableName: tableName,
    Limit: count,
  }))
  console.log(`found ${resp.Items.length} restaurants`)
  return resp.Items
}

export const handler = middy(async (event, context) => {
  const restaurants = await getRestaurants(context.config.defaultResults)
  const response = {
    statusCode: 200,
    body: JSON.stringify(restaurants)
  }

  return response
}).use(ssm({
  cache: true,
  cacheExpiry: 1 * 60 * 1000, // 1 mins
  setToContext: true,
  fetchData: {
    config: `/${service_name}/${stage_name}/get-restaurants/config`
  }
}))


