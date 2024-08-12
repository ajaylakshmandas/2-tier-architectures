from flask import Flask, request, jsonify
import boto3

app = Flask(__name__)

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='your-region')
table = dynamodb.Table('YourTableName')

@app.route('/submit', methods=['POST'])
def submit_name():
    data = request.get_json()
    name = data.get('name')
    if name:
        table.put_item(Item={'name': name})
        return jsonify({'message': 'Name submitted successfully!'}), 200
    return jsonify({'message': 'Name is required!'}), 400

if __name__ == '__main__':
    app.run(debug=True)
