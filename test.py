from tokenize import String
import requests
from bs4 import BeautifulSoup
from win10toast import ToastNotifier
import sys

r = requests.get('https://ptsv2.com/t/pp')

html = r.text
soup = BeautifulSoup(html, 'html.parser')

posts = soup.find_all('td', string="POST")
latest_post = posts[-1].parent

idnum = latest_post.findChildren("td")[0].text

r = requests.get('https://ptsv2.com/t/pp/d/'+idnum)

html = r.text
soup = BeautifulSoup(html, 'html.parser')

goal_child = soup.find('td', string="goal")
goal_parent = goal_child.parent.text.replace(" ", "").replace("\r", "").split("\n")

time_child = soup.find('td', string="time")
time_parent = time_child.parent.text.replace(" ", "").replace("\r", "").split("\n")

while '' in goal_parent:
    goal_parent.remove('')

goal = goal_parent[1]

while '' in time_parent:
    time_parent.remove('')

time = time_parent[1]

result = float(time) / float(goal)

if result != "100":
    toast = ToastNotifier()

    message = '현재 진행률:'+" "+str(result)+"% | "+'운동한 시간:'+" "+str(int(float(time)))+"분 | "+'목표 시간:'+" "+str(int(float(goal)))+"분"

    toast.show_toast("운동할 시간", str(message), duration = 10)
elif time == "90000.0" or goal == "90000.00":
    toast = ToastNotifier()

    toast.show_toast("운동할 시간", "운동 데이터가 유효하지 않습니다.", duration = 10)

sys.exit(0)