#define _CRT_SECURE_NO_DEPRECATE
#include "testlib.h"

#define forn(i, n) for (int i = 0; i < (int)(n); ++i)
#define forv(i, v) for (int i = 0; i < (int)(v.size()); ++i)
#define fors(i, s) for (int i = 0; i < (int)(s.length()); ++i)
#define all(a) a.begin(), a.end()
#define pb push_back
#define PII pair<long long, long long>
#define mp make_pair
#define VI vector<long long>
#define VS vector<string>

#include "geometry_vg_checker.h"

int n;
polygon a;
vectD d;
vector<point> v;
vector< vector<point> > g;
vector< vector<bool> > u;
polygon cFace;
int contestantU;

int num(point p) {
    return (int)(lower_bound(all(v), p) - v.begin());
}

void uniq(vector<point> &v) {
    sort(all(v));
    v.erase(unique(all(v)), v.end());
}

void push(point &p1, point &p2) {
    int u = num(p1), v = num(p2);
    g[u].pb(p2 - p1);
    g[v].pb(p1 - p2);
}

void face(int c, int r) {
    while (!u[c][r]) {
        u[c][r] = true;
        point p = v[c];
        cFace.pb(p);
        point np = g[c][(r + 1) % g[c].size()] + p;
        int nv = num(np);
        point df = p - np;
        assert(binary_search(all(g[nv]), df, lessP));
        int nr = (int)(lower_bound(all(g[nv]), p - np, lessP) - g[nv].begin());
        c = nv;
        r = nr;
    }   
}

void solve() {
    forv(i, d) {
        forn(j, i) {
            point p;
            if (cross(d[i], d[j], p)) {
                v.pb(p);
            }
        }
    }
    uniq(v);
    g.resize(v.size());
    u.resize(v.size());
    forv(i, d) {
        vector<point> cv;
        cv.pb(d[i].p1);
        cv.pb(d[i].p2);
        forv(j, d) {
            point p;
            if (cross(d[i], d[j], p)) {
                cv.pb(p);
            }
        }
        uniq(cv);
        forn(i, (int)cv.size() - 1) {
            push(cv[i], cv[i + 1]);
        }
    }
    forv(i, v) {
        sort(all(g[i]), lessP);
        g[i].erase(unique(all(g[i]), eqP), g[i].end());
        u[i] = vector<bool>(g[i].size(), false);
    }
    face(0, (int)g[0].size() - 1 /* or 0 */);
    norm(cFace);
    assert(cFace.size() == n);
    int contestantAnswer = 0;
    forv(i, v) {
        forv(j, g[i]) {
            if (!u[i][j]) {
                cFace.clear();
                face(i, j);
                norm(cFace);
                assert(cFace.size() >= 3);
                if (cFace.size() > 3) {
//                    cerr << cFace.size() << endl;
//                    forv(i, cFace) cerr << cFace[i].x << " " << cFace[i].y << endl;
                    quitf(_wa, "Одна из областей является %d-угольником, а не треугольником", cFace.size());
                } else {
                    ++contestantAnswer;
                }
            }
        }
    }
    if (contestantU != contestantAnswer) quitf(_wa  , "Неверно указано количество треугольников (указано %d, на самом деле - %d)", contestantU, contestantAnswer);
    int juryAnswer = ans.readInt();
    if (juryAnswer > contestantAnswer) quitf(_fail, "Лучше, чем у НК! (%d вместо %d)", contestantAnswer, juryAnswer);
    if (juryAnswer < contestantAnswer) quitf(_wa  , "Количество треугольников не минимальное (%d вместо %d)", contestantAnswer, juryAnswer);
    int tmp = juryAnswer % 100;
    if ((tmp / 10 == 1) || (tmp % 10 >= 5) || (tmp % 10 == 0))
        quitf(_ok, "%d треугольников", juryAnswer);
    if ((tmp % 10 >= 2))
        quitf(_ok, "%d треугольника", juryAnswer);
    quitf(_ok, "%d треугольник", juryAnswer);
}

int main(int argc, char * argv[])
{
    registerTestlibCmd(argc, argv);
    n = inf.readInt();
    a.resize(n);
    forn(i, n) {
        a[i].x = inf.readDouble();
        a[i].y = inf.readDouble();
        v.pb(a[i]);
    }
    contestantU = ouf.readInt();
    if (contestantU < 0) quitf(_wa, "Количество областей отрицательно (%d)", contestantU);
    int k = ouf.readInt();
    if (k < 0) quitf(_wa, "Количество диагоналей отрицательно (%d)", k);
    if (k > 200) quitf(_wa, "Слишком много диагоналей (%d)", k);
    d.resize(k);
    forn(i, k) {
        d[i].p1.x = ouf.readInt();
        d[i].p1.y = ouf.readInt();
        d[i].p2.x = ouf.readInt();
        d[i].p2.y = ouf.readInt();
        if (d[i].p1 > d[i].p2)
          swap(d[i].p1, d[i].p2);
        v.pb(d[i].p1);
        v.pb(d[i].p2);
    }
    sort(all(d));
    if (unique(all(d)) != d.end())
        quitf(_wa, "Одна диагональ выведена несколько раз");
    forv(i, d) {
        if (!onPolygonV(d[i].p1, a)) quitf(_wa, "Конец отрезка не является вершиной: (%.0f %.0f)", d[i].p1.x, d[i].p1.y);
        if (!onPolygonV(d[i].p2, a)) quitf(_wa, "Конец отрезка не является вершиной: (%.0f %.0f)", d[i].p2.x, d[i].p2.y);
        if (!inPolygon(d[i], a)) quitf(_wa, "Отрезок не является внутренней диагональю: (%.0f %.0f) - (%.0f %.0f)",
            d[i].p1.x, d[i].p1.y, d[i].p2.x, d[i].p2.y);
        forv(j, a) {
            if (d[i] == segment(a[j], a[next(j)])) quitf(_wa, "Отрезок совпадает со стороной: (%.0f %.0f) - (%.0f %.0f)",
                d[i].p1.x, d[i].p1.y, d[i].p2.x, d[i].p2.y);
        }
    }
    forn(i, n) {
        d.pb(segment(a[i], a[next(i)]));
    }
    solve();
    return 0;
}
