from flask import Flask, request, jsonify
import requests
import re

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def webhook():
    if request.method == 'GET':

        return "Hello, World!"

    elif request.method == 'POST':
        data = process_grafana_data(request.json)
        print(data, flush=True)

        response = send_request_to_service(data)
        print(response, flush=True)
        
        return jsonify(response)

def process_grafana_data(data):
    pattern = r'(Source: )(http[s]?://\S+)'
    replacement = r'[Click To Prometheus Check ...](\2)'
    data["text"] = re.sub(pattern, replacement, data["text"])

    data = {
        "type": "message",
        "attachments": [
            {
                "contentType": "application/vnd.microsoft.card.adaptive",
                "content": {
                    "type": "AdaptiveCard",
                    "version": "1.2",
                    "body": [
                        {
                            "type": "TextBlock",
                            "text": data["text"],
                            "wrap": "true"
                        }
                    ],
                    "msteams": {
                        "width": "Full"
                    }
                }
            }
        ]
    }

    return data

def send_request_to_service(data):
    webhook = "https://"
    response = requests.post(webhook, json=data)

    if response.content:
        return response.json()
    else:
        return {"status": "success"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
