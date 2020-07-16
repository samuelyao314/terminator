#pragma once
#include <list>
#include <vector>
#include <map>
#include <unordered_map>
#include <assert.h>
#include <utility>
#include <functional>

template<typename TKEY, template<typename...> class MAP_TYPE = std::map>
class lru {
public:
    lru(int size) {
        m_size = size;
        m_next_index = 1;
        lru_reserve(m_iter_map, size);
    }

    ~lru() {
    }

    int get(const TKEY& key) {
        auto map_it = m_iter_map.find(key);
        if (map_it == m_iter_map.end()) {
            return 0;
        }

        auto list_it = map_it->second;
        int index = list_it->index;
        m_node_list.push_front(*list_it);
        m_node_list.erase(list_it);
        map_it->second = m_node_list.begin();
        return index;
    }

    int set(const TKEY& key, const std::function<void(int, const TKEY&)>& discard_callback) {
        auto map_it = m_iter_map.find(key);
        if (map_it != m_iter_map.end()) {
            auto list_it = map_it->second;
            int index = list_it->index;
            m_node_list.push_front(*list_it);
            m_node_list.erase(list_it);
            map_it->second = m_node_list.begin();
            return index;
        }

        int index = 0;
        if (count() >= m_size) {
            node& last = m_node_list.back();
            index = last.index;

            if (discard_callback != nullptr)
                discard_callback(index, last.key);

            m_iter_map.erase(last.key);
            m_node_list.pop_back();
            m_node_list.push_front({key, index});
            m_iter_map[key] =  m_node_list.begin();
            return index;
        }

        if (m_free_list.empty()) {
            index = m_next_index++;
        } else {
            index = m_free_list.back();
            m_free_list.pop_back();
        }

        m_node_list.push_front({ key, index });
        m_iter_map[key] = m_node_list.begin();
        return index;
    }

    int del(const TKEY& key) {
        auto map_it = m_iter_map.find(key);
        if (map_it == m_iter_map.end())
            return 0;

        auto list_it = map_it->second;
        int index = list_it->index;
        m_node_list.erase(list_it);
        m_iter_map.erase(map_it);
        m_free_list.push_back(index);
        return index;
    }

    int first(TKEY& key) {
        if (m_iter_map.empty())
            return 0;

        auto map_it = m_iter_map.begin();
        node& data = *(map_it->second);
        key = data.key;
        return data.index;
    }

    int next(TKEY& key) {
        auto map_it = m_iter_map.find(key);
        if (map_it == m_iter_map.end())
            return 0;

        if (++map_it == m_iter_map.end())
            return 0;

        node& data = *(map_it->second);
        key = data.key;
        return data.index;
    }

    int count() {
        // 这里使用map.size()，因为有些版本的stl计算list.size()的复杂度是线性的
        return (int)m_iter_map.size();
    }

    void resize(std::vector<int>& remove_list, int size) {
        int remve_num = count() - size;
        for (int i = 0; i < remve_num; i++) {
            node& last = m_node_list.back();
            remove_list.push_back(last.index);
            m_iter_map.erase(last.key);
            m_free_list.push_back(last.index);
            m_node_list.pop_back();
        }
        m_size = size;
    }

    // 这里并没有返回被清除的对象列表,调用者要负责清除lua数组中存储的所有对象
    void clear() {
        m_next_index = 1;
        m_free_list.clear();
        m_node_list.clear();
        m_iter_map.clear();
    }

private:
    struct node {
        TKEY key;
        int index;
    };

    template <class T>
    auto lru_reserve(T& obj, int size) -> decltype(std::declval<T>().reserve(0)) {  obj.reserve(size); }

    template <class T>
    void lru_reserve(T&, ...) { }

private:
    int m_size;
    int m_next_index;
    std::vector<int> m_free_list;
    std::list<node> m_node_list;
    MAP_TYPE<TKEY, typename std::list<node>::iterator> m_iter_map;
};

